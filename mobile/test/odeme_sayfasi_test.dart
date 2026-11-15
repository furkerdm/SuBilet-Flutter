import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/enumlar.dart';
import 'package:mobile/models/odeme_sonucu.dart';
import 'package:mobile/models/sefer.dart';
import 'package:mobile/odeme_sayfasi.dart';
import 'package:mobile/widgets/bilet_onay_diyalogu.dart';

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

  const koltuklar = {7: Cinsiyet.erkek, 3: Cinsiyet.kadin};

  // Sayfa bir "Ana sayfa"nın üstüne açılır; böylece onaydan sonra ana sayfaya
  // dönüş de sınanır
  Future<void> sayfayiAc(
    WidgetTester tester, {
    List<String> pnrler = const ['SB2K7P', 'TR4M9Z'],
    Duration islemSuresi = Duration.zero,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var sira = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OdemeSayfasi(
                      sefer: sefer,
                      koltuklar: koltuklar,
                      pnrUret: () => pnrler[sira++ % pnrler.length],
                      islemSuresi: islemSuresi,
                      simdi: DateTime(2026, 11, 15),
                    ),
                  ),
                ),
                child: const Text('Ana sayfa'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ana sayfa'));
    await tester.pumpAndSettle();
  }

  Future<void> yaz(WidgetTester tester, String alan, String metin) async {
    final bulucu = find.byKey(ValueKey(alan));
    await tester.ensureVisible(bulucu);
    await tester.enterText(bulucu, metin);
  }

  Future<void> kartiDoldur(
    WidgetTester tester, {
    String numara = '4242424242424242',
    String sonKullanma = '1228',
  }) async {
    await yaz(tester, 'kartSahibi', 'Ayşe Yılmaz');
    await yaz(tester, 'kartNumarasi', numara);
    await yaz(tester, 'sonKullanma', sonKullanma);
    await yaz(tester, 'cvv', '123');
  }

  Future<void> odemeYap(WidgetTester tester) async {
    await tester.tap(find.text('1000 TL Öde'));
    await tester.pumpAndSettle();
  }

  testWidgets('Sefer, koltuklar ve toplam tutar gösterilir', (tester) async {
    await sayfayiAc(tester);

    expect(find.text('Anadolu Ekspres'), findsOneWidget);
    expect(find.text('Koltuk 3 · Kadın'), findsOneWidget);
    expect(find.text('Koltuk 7 · Erkek'), findsOneWidget);
    expect(find.text('1000 TL'), findsOneWidget);
    expect(find.text('1000 TL Öde'), findsOneWidget);

    // Koltuklar numara sırasıyla listelenir
    expect(
      tester.getTopLeft(find.text('Koltuk 3 · Kadın')).dy,
      lessThan(tester.getTopLeft(find.text('Koltuk 7 · Erkek')).dy),
    );
  });

  testWidgets('Boş form gönderilmez, her alan için hata çıkar', (tester) async {
    await sayfayiAc(tester);
    await odemeYap(tester);

    expect(find.byType(BiletOnayDiyalogu), findsNothing);
    expect(find.text('Kart üzerindeki adı girin.'), findsOneWidget);
    expect(find.text('Kart numarasını girin.'), findsOneWidget);
    expect(
      find.text('Son kullanma tarihini AA/YY biçiminde girin.'),
      findsOneWidget,
    );
    expect(
      find.text('Kartın arkasındaki 3 haneli kodu girin.'),
      findsOneWidget,
    );
  });

  testWidgets('Luhn\'a uymayan kart ve geçmiş tarih reddedilir', (
    tester,
  ) async {
    await sayfayiAc(tester);
    await kartiDoldur(tester, numara: '4242424242424241', sonKullanma: '1026');
    await odemeYap(tester);

    expect(find.byType(BiletOnayDiyalogu), findsNothing);
    expect(find.text('Kart numarası geçersiz.'), findsOneWidget);
    expect(find.text('Kartın son kullanma tarihi geçmiş.'), findsOneWidget);
  });

  testWidgets('Alanlar yazarken biçimlenir', (tester) async {
    await sayfayiAc(tester);
    await kartiDoldur(tester);
    await tester.pump();

    expect(find.text('4242 4242 4242 4242'), findsOneWidget);
    expect(find.text('12/28'), findsOneWidget);
  });

  testWidgets('Ödeme sonrası her koltuğun PNR kodu diyalogda gösterilir', (
    tester,
  ) async {
    await sayfayiAc(tester, islemSuresi: const Duration(seconds: 1));
    await kartiDoldur(tester, numara: '5555555555554444');

    await tester.tap(find.text('1000 TL Öde'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ödeme işleniyor...'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(BiletOnayDiyalogu), findsOneWidget);
    expect(find.text('Ödeme başarılı'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('pnr-3'))).data,
      'SB2K7P',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('pnr-7'))).data,
      'TR4M9Z',
    );
    expect(find.text('**** **** **** 4444'), findsOneWidget);
    expect(find.text('20.11.2026 Cuma 09:30'), findsOneWidget);

    // Kart bilgileri ekranda bırakılmaz
    final numara = tester.widget<TextFormField>(
      find.byKey(const ValueKey('kartNumarasi')),
    );
    expect(numara.controller!.text, isEmpty);

    // Diyalog dışına dokunmak onu kapatmaz
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(BiletOnayDiyalogu), findsOneWidget);

    await tester.tap(find.text('Ana Sayfaya Dön'));
    await tester.pumpAndSettle();
    expect(find.byType(BiletOnayDiyalogu), findsNothing);
    expect(find.byType(OdemeSayfasi), findsNothing);
    expect(find.text('Ana sayfa'), findsOneWidget);
  });

  testWidgets('Aynı satın almada iki bilete aynı PNR verilmez', (tester) async {
    await sayfayiAc(tester, pnrler: ['AAAAAA', 'AAAAAA', 'BBBBBB']);
    await kartiDoldur(tester);
    await odemeYap(tester);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('pnr-3'))).data,
      'AAAAAA',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('pnr-7'))).data,
      'BBBBBB',
    );
  });

  test('Geçici PNR üreticisi 6 karakter ve izinli karakterlerle üretir', () {
    for (var i = 0; i < 200; i++) {
      final pnr = PnrUretici.uret();
      expect(pnr.length, PnrUretici.uzunluk);
      expect(pnr.split('').every(PnrUretici.karakterler.contains), isTrue);
    }
  });
}
