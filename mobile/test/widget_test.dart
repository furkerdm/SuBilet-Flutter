import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';
import 'package:mobile/sehirler.dart';

// Kalkış ya da varış alanında gösterilen şehri bulur
Finder alandakiSehir(String alan, String sehir) => find.descendant(
  of: find.widgetWithText(ListTile, alan),
  matching: find.text(sehir),
);

// Açılır listeyi açar, şehre kadar kaydırır ve seçer
Future<void> sehirSec(WidgetTester tester, String alanKey, String sehir) async {
  final secim = find.byKey(ValueKey(alanKey));
  final mevcut = tester.widget<DropdownButton<String>>(secim).value!;
  await tester.tap(secim);
  await tester.pumpAndSettle();

  // Liste seçili şehirde açılır; aranan şehir yukarıdaysa yukarı kaydırılır
  final yukari = sehirler.indexOf(sehir) < sehirler.indexOf(mevcut);
  final menudekiSehir = find.widgetWithText(DropdownMenuItem<String>, sehir);
  await tester.scrollUntilVisible(
    menudekiSehir,
    yukari ? -150 : 150,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  // Öğenin ortası boş kalabildiği için öğeyi saran InkWell'e dokunulur
  await tester.tap(
    find.ancestor(of: menudekiSehir, matching: find.byType(InkWell)).first,
  );
  await tester.pumpAndSettle();
}

ButtonStyleButton aramaButonu(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Otobüs Bileti Bul'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );

String tarihMetni(DateTime tarih) =>
    '${tarih.day.toString().padLeft(2, '0')}.'
    '${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';

void main() {
  testWidgets('Açılışta Ankara - İstanbul ve bugün seçili gelir', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());

    expect(alandakiSehir('Kalkış Noktası', 'Ankara'), findsOneWidget);
    expect(alandakiSehir('Varış Noktası', 'İstanbul'), findsOneWidget);
    expect(find.textContaining('(Bugün)'), findsOneWidget);
    expect(aramaButonu(tester).enabled, isTrue);
  });

  testWidgets('Yön değiştirme butonu şehirlerin yerini değiştirir', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());
    await tester.tap(find.byTooltip('Yön Değiştir'));
    await tester.pump();

    expect(alandakiSehir('Kalkış Noktası', 'İstanbul'), findsOneWidget);
    expect(alandakiSehir('Varış Noktası', 'Ankara'), findsOneWidget);
  });

  testWidgets('Şehir listelerinde 81 ilin tamamı var', (tester) async {
    await tester.pumpWidget(const SuBiletApp());

    expect(sehirler, hasLength(81));
    expect(sehirler.toSet(), hasLength(81));
    for (final alan in ['kalkisSecimi', 'varisSecimi']) {
      final secim = tester.widget<DropdownButton<String>>(
        find.byKey(ValueKey(alan)),
      );
      expect(secim.items!.map((oge) => oge.value), sehirler);
    }
  });

  testWidgets('Açılır listeden seçilen şehir kalkış noktası olur', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());
    await sehirSec(tester, 'kalkisSecimi', 'Zonguldak');

    expect(alandakiSehir('Kalkış Noktası', 'Zonguldak'), findsOneWidget);
    expect(
      find.text('Kalkış noktası Zonguldak olarak seçildi.'),
      findsOneWidget,
    );
  });

  testWidgets('Açılır listeden seçilen şehir varış noktası olur', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());
    await sehirSec(tester, 'varisSecimi', 'Adana');

    expect(alandakiSehir('Varış Noktası', 'Adana'), findsOneWidget);
    expect(find.text('Varış noktası Adana olarak seçildi.'), findsOneWidget);
    expect(aramaButonu(tester).enabled, isTrue);
  });

  testWidgets('Kalkış ve varış aynıysa arama butonu pasif olur', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());
    await sehirSec(tester, 'varisSecimi', 'Ankara');

    expect(find.text('Kalkış ve varış noktası aynı olamaz.'), findsOneWidget);
    expect(aramaButonu(tester).enabled, isFalse);
  });

  testWidgets('Yarın butonu tarihi bir gün ileri alır', (tester) async {
    await tester.pumpWidget(const SuBiletApp());
    await tester.tap(find.text('Yarın'));
    await tester.pump();

    final bugun = DateUtils.dateOnly(DateTime.now());
    final yarin = DateUtils.addDaysToDate(bugun, 1);
    expect(
      find.text('Seyahat Tarihi: ${tarihMetni(yarin)} (Yarın)'),
      findsOneWidget,
    );
  });

  testWidgets('Takvim butonu Türkçe tarih seçiciyi açar', (tester) async {
    await tester.pumpWidget(const SuBiletApp());
    await tester.tap(find.text('Takvimden Tarih Seç'));
    await tester.pumpAndSettle();

    expect(find.text('Seyahat tarihini seçin'), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();

    expect(find.text('Seyahat tarihini seçin'), findsNothing);
    expect(find.textContaining('(Bugün)'), findsOneWidget);
  });
}
