import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

// Kalkış ya da varış alanında gösterilen şehri bulur
Finder alandakiSehir(String alan, String sehir) => find.descendant(
  of: find.widgetWithText(ListTile, alan),
  matching: find.text(sehir),
);

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

  testWidgets('Listeden seçilen şehir kalkış noktası olur', (tester) async {
    await tester.pumpWidget(const SuBiletApp());
    await tester.tap(find.text('Kalkış Noktası'));
    await tester.pumpAndSettle();

    expect(find.text('Nereden?'), findsOneWidget);
    await tester.tap(find.text('Antalya'));
    await tester.pumpAndSettle();

    expect(alandakiSehir('Kalkış Noktası', 'Antalya'), findsOneWidget);
    expect(find.text('Kalkış noktası Antalya olarak seçildi.'), findsOneWidget);
  });

  testWidgets('Kalkış ve varış aynıysa arama butonu pasif olur', (
    tester,
  ) async {
    await tester.pumpWidget(const SuBiletApp());
    await tester.tap(find.text('Varış Noktası'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Ankara'),
      ),
    );
    await tester.pumpAndSettle();

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
