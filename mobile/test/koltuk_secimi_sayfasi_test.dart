import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/koltuk_secimi_sayfasi.dart';
import 'package:mobile/models/enumlar.dart';
import 'package:mobile/models/sefer.dart';
import 'package:mobile/widgets/koltuk_dugmesi.dart';

void main() {
  final sefer = Sefer(
    id: 1,
    firmaId: 1,
    firmaAdi: 'Anadolu Ekspres',
    otobusId: 11,
    koltukDuzeni: KoltukDuzeni.ikiArtiIki,
    kalkisSehirId: 6,
    kalkisSehirAdi: 'Ankara',
    varisSehirId: 34,
    varisSehirAdi: 'İstanbul',
    kalkisZamani: DateTime(2026, 11, 20, 9, 30),
    tahminiVarisZamani: DateTime(2026, 11, 20, 15, 0),
    fiyat: 500,
  );

  // 2+2, iki sıra: 1 kadın ve 4 erkek yolcuya satılmış
  //   1K  2 | 3  4E
  //    5  6 | 7  8
  Future<void> sayfayiAc(
    WidgetTester tester, {
    int koltukSayisi = 8,
    Map<int, Cinsiyet> dolu = const {1: Cinsiyet.kadin, 4: Cinsiyet.erkek},
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: KoltukSecimiSayfasi(
          sefer: sefer,
          koltukSayisi: koltukSayisi,
          doluKoltuklar: dolu,
        ),
      ),
    );
  }

  Finder koltuk(int no) => find.byKey(ValueKey('koltuk-$no'));

  KoltukDugmesi dugme(WidgetTester tester, int no) =>
      tester.widget<KoltukDugmesi>(koltuk(no));

  Future<void> koltukSec(WidgetTester tester, int no, String cinsiyet) async {
    await tester.tap(koltuk(no));
    await tester.pumpAndSettle();
    await tester.tap(find.text(cinsiyet));
    await tester.pumpAndSettle();
  }

  String? toplam(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('toplamTutar'))).data;

  FilledButton devamDugmesi(WidgetTester tester) => tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Devam Et'),
  );

  testWidgets('Koltuklar çizilir, dolu koltuklar cinsiyete göre renklenir', (
    tester,
  ) async {
    await sayfayiAc(tester);

    expect(find.byType(KoltukDugmesi), findsNWidgets(8));
    expect(dugme(tester, 1).doluCinsiyet, Cinsiyet.kadin);
    expect(dugme(tester, 4).doluCinsiyet, Cinsiyet.erkek);
    expect(dugme(tester, 2).doluCinsiyet, isNull);

    // Dolu koltuğa dokunmak bir şey açmaz
    await tester.tap(koltuk(1));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsNothing);
    expect(devamDugmesi(tester).onPressed, isNull);
  });

  testWidgets('Boş koltuğa dokununca cinsiyet sorulur ve koltuk seçilir', (
    tester,
  ) async {
    await sayfayiAc(tester);

    await tester.tap(koltuk(6));
    await tester.pumpAndSettle();
    expect(find.text('6 numaralı koltuk'), findsOneWidget);

    await tester.tap(find.text('Erkek'));
    await tester.pumpAndSettle();

    expect(dugme(tester, 6).seciliCinsiyet, Cinsiyet.erkek);
    expect(find.widgetWithText(InputChip, '6 · Erkek'), findsOneWidget);
    expect(toplam(tester), '500 TL');
    expect(devamDugmesi(tester).onPressed, isNotNull);

    await koltukSec(tester, 7, 'Kadın');
    expect(toplam(tester), '1000 TL');
  });

  testWidgets('Cinsiyet sorusu kapatılırsa koltuk seçilmez', (tester) async {
    await sayfayiAc(tester);

    await tester.tap(koltuk(6));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5)); // diyaloğun dışına dokunulur
    await tester.pumpAndSettle();

    expect(dugme(tester, 6).seciliCinsiyet, isNull);
  });

  testWidgets('Yan koltuk kuralı çiğnenirse AlertDialog ile uyarılır', (
    tester,
  ) async {
    await sayfayiAc(tester);

    // 2'nin yanı (1) kadın yolcuya satılmış: erkek yolcu oturamaz
    await koltukSec(tester, 2, 'Erkek');

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Bu koltuk seçilemez'), findsOneWidget);
    expect(
      find.textContaining('Yanındaki 1 numaralı koltukta kadın yolcu'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(dugme(tester, 2).seciliCinsiyet, isNull);

    // Kadın yolcu için seçilebilir
    await koltukSec(tester, 2, 'Kadın');
    expect(find.byType(AlertDialog), findsNothing);
    expect(dugme(tester, 2).seciliCinsiyet, Cinsiyet.kadin);

    // 3'ün yanı (4) erkek yolcuya satılmış
    await koltukSec(tester, 3, 'Kadın');
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Seçili koltuğa yeniden dokununca ya da çip silinince seçim '
      'kaldırılır', (tester) async {
    await sayfayiAc(tester);
    await koltukSec(tester, 5, 'Erkek');
    await koltukSec(tester, 6, 'Erkek');

    await tester.tap(koltuk(5));
    await tester.pumpAndSettle();
    expect(dugme(tester, 5).seciliCinsiyet, isNull);
    expect(find.byType(SimpleDialog), findsNothing);

    await tester.tap(find.byTooltip('Kaldır'));
    await tester.pumpAndSettle();
    expect(dugme(tester, 6).seciliCinsiyet, isNull);
    expect(find.byType(InputChip), findsNothing);
    expect(devamDugmesi(tester).onPressed, isNull);
  });

  testWidgets('En fazla 5 koltuk seçilebilir', (tester) async {
    await sayfayiAc(tester, koltukSayisi: 12, dolu: const {});

    for (final no in [1, 2, 3, 4, 5]) {
      await koltukSec(tester, no, 'Erkek');
    }
    await tester.tap(koltuk(6));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsNothing);
    expect(
      find.text('Bir seferde en fazla 5 koltuk seçebilirsiniz.'),
      findsOneWidget,
    );
    expect(dugme(tester, 6).seciliCinsiyet, isNull);
  });

  testWidgets('Koltuk sayısı ve dolu koltuklar verilmezse örnek veri '
      'kullanılır', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: KoltukSecimiSayfasi(sefer: sefer)),
    );

    // 2+2 örnek otobüs 46 koltuklu; liste kaydırılabilir olduğu için
    // ekrandakilerin bir kısmı dolu olmalı
    final dugmeler = tester.widgetList<KoltukDugmesi>(
      find.byType(KoltukDugmesi, skipOffstage: false),
    );
    expect(dugmeler.map((d) => d.no), contains(1));
    expect(dugmeler.where((d) => d.doluCinsiyet != null), isNotEmpty);
  });
}
