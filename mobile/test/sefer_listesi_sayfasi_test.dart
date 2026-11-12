import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/koltuk_secimi_sayfasi.dart';
import 'package:mobile/sefer_listesi_sayfasi.dart';
import 'package:mobile/widgets/sefer_karti.dart';

void main() {
  Widget sayfa() {
    return MaterialApp(
      home: SeferListesiSayfasi(
        kalkisSehir: 'Ankara',
        varisSehir: 'İstanbul',
        tarih: DateTime(2026, 11, 20),
      ),
    );
  }

  // Ekrandaki kartların sırasıyla fiyatları
  List<double> fiyatlar(WidgetTester tester) => tester
      .widgetList<SeferKarti>(find.byType(SeferKarti))
      .map((kart) => kart.sefer.fiyat)
      .toList();

  // Tüm kartlar aynı anda görünsün diye uzun bir ekran
  void uzunEkran(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> siralamaSec(WidgetTester tester, String secenek) async {
    await tester.tap(find.byType(DropdownButton<SeferSiralamasi>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(secenek).last);
    await tester.pumpAndSettle();
  }

  // Çip satırı yatay kaydığı için önce çipe kaydırılır
  Future<void> firmaSec(WidgetTester tester, String firma) async {
    final cip = find.widgetWithText(ChoiceChip, firma);
    await tester.ensureVisible(cip);
    await tester.pumpAndSettle();
    await tester.tap(cip);
    await tester.pumpAndSettle();
  }

  testWidgets('Seferler Card ve ListTile ile kart olarak listelenir', (
    tester,
  ) async {
    uzunEkran(tester);
    await tester.pumpWidget(sayfa());

    expect(find.byType(SeferKarti), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byType(SeferKarti),
        matching: find.byType(ListTile),
      ),
      findsNWidgets(5),
    );
    expect(find.text('5 sefer'), findsOneWidget);

    // Saatler, süre, koltuk düzeni ve fiyat kartta görünür
    final kart = find.ancestor(
      of: find.text('450 TL'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(
        of: kart,
        matching: find.text('09:30 → 15:00 · 5 sa 30 dk\n2+1 koltuk düzeni'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Seferler varsayılan olarak kalkış saatine göre sıralanır', (
    tester,
  ) async {
    uzunEkran(tester);
    await tester.pumpWidget(sayfa());

    final kalkislar = tester
        .widgetList<SeferKarti>(find.byType(SeferKarti))
        .map((kart) => kart.sefer.kalkisZamani.hour)
        .toList();
    expect(kalkislar, [7, 9, 13, 17, 23]);
  });

  testWidgets('Seferler fiyata göre artan ve azalan sıralanabilir', (
    tester,
  ) async {
    uzunEkran(tester);
    await tester.pumpWidget(sayfa());

    await siralamaSec(tester, 'En düşük fiyat');
    expect(fiyatlar(tester), [390, 420, 450, 480, 510]);

    await siralamaSec(tester, 'En yüksek fiyat');
    expect(fiyatlar(tester), [510, 480, 450, 420, 390]);
  });

  testWidgets('Firma filtresi yalnızca seçili firmanın seferlerini gösterir', (
    tester,
  ) async {
    uzunEkran(tester);
    await tester.pumpWidget(sayfa());

    await firmaSec(tester, 'Ege Yıldızı Turizm');

    final firmalar = tester
        .widgetList<SeferKarti>(find.byType(SeferKarti))
        .map((kart) => kart.sefer.firmaAdi)
        .toSet();
    expect(firmalar, {'Ege Yıldızı Turizm'});
    expect(find.text('2 sefer'), findsOneWidget);

    // Seçili firmaya yeniden dokunmak filtreyi kaldırır
    await firmaSec(tester, 'Ege Yıldızı Turizm');
    expect(find.byType(SeferKarti), findsNWidgets(5));

    // Filtre ile sıralama birlikte çalışır
    await firmaSec(tester, 'Anadolu Ekspres');
    await siralamaSec(tester, 'En yüksek fiyat');
    expect(fiyatlar(tester), [450, 390]);

    await firmaSec(tester, 'Tüm firmalar');
    expect(find.byType(SeferKarti), findsNWidgets(5));
  });

  testWidgets('Sefer yoksa boş durum gösterilir ve aramaya dönülür', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeferListesiSayfasi(
                    kalkisSehir: 'Ankara',
                    varisSehir: 'İstanbul',
                    tarih: DateTime(2026, 11, 20),
                    seferler: const [],
                  ),
                ),
              ),
              child: const Text('Ara'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();

    expect(find.text('Sefer bulunamadı'), findsOneWidget);
    expect(find.byType(SeferKarti), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(DropdownButton<SeferSiralamasi>), findsNothing);

    await tester.tap(find.text('Aramayı Değiştir'));
    await tester.pumpAndSettle();
    expect(find.text('Ara'), findsOneWidget);
    expect(find.byType(SeferListesiSayfasi), findsNothing);
  });

  testWidgets('Küçük ekranda sefer listesi taşmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(sayfa());
    expect(tester.takeException(), isNull);

    await siralamaSec(tester, 'En yüksek fiyat');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sefer kartına dokununca o seferin koltuk seçimi açılır', (
    tester,
  ) async {
    uzunEkran(tester);
    await tester.pumpWidget(sayfa());

    final ilkKart = tester.widget<SeferKarti>(find.byType(SeferKarti).first);
    await tester.tap(find.byType(SeferKarti).first);
    await tester.pumpAndSettle();

    final koltukSayfasi = tester.widget<KoltukSecimiSayfasi>(
      find.byType(KoltukSecimiSayfasi),
    );
    expect(koltukSayfasi.sefer, same(ilkKart.sefer));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(KoltukSecimiSayfasi), findsNothing);
  });
}
