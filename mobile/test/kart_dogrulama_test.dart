import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/kart_dogrulama.dart';
import 'package:mobile/widgets/kart_bicimleyicileri.dart';

void main() {
  group('Luhn', () {
    test('geçerli kart numaralarını kabul eder', () {
      expect(KartDogrulama.luhnGecerliMi('4242 4242 4242 4242'), isTrue);
      expect(KartDogrulama.luhnGecerliMi('4111111111111111'), isTrue);
      expect(KartDogrulama.luhnGecerliMi('5555-5555-5555-4444'), isTrue);
      expect(KartDogrulama.luhnGecerliMi('79927398713'), isTrue);
    });

    test('tek hanesi değişen numarayı reddeder', () {
      expect(KartDogrulama.luhnGecerliMi('4242424242424241'), isFalse);
      expect(KartDogrulama.luhnGecerliMi('79927398710'), isFalse);
      expect(KartDogrulama.luhnGecerliMi(''), isFalse);
    });

    test('kart numarası 16 haneli ve Luhn uyumlu olmalı', () {
      expect(KartDogrulama.kartNumarasiHatasi('4242 4242 4242 4242'), isNull);
      expect(KartDogrulama.kartNumarasiHatasi(''), 'Kart numarasını girin.');
      expect(
        KartDogrulama.kartNumarasiHatasi('79927398713'),
        'Kart numarası 16 haneli olmalıdır.',
      );
      expect(
        KartDogrulama.kartNumarasiHatasi('4242 4242 4242 4241'),
        'Kart numarası geçersiz.',
      );
    });
  });

  group('Son kullanma tarihi', () {
    final simdi = DateTime(2026, 11, 15);
    String? hata(String metin) =>
        KartDogrulama.sonKullanmaHatasi(metin, simdi: simdi);

    test('içinde bulunulan ay ve sonrası geçerlidir', () {
      expect(hata('11/26'), isNull);
      expect(hata('12/26'), isNull);
      expect(hata('01/31'), isNull);
    });

    test('geçmiş ay, yanlış ay ve biçim reddedilir', () {
      expect(hata('10/26'), 'Kartın son kullanma tarihi geçmiş.');
      expect(hata('12/25'), 'Kartın son kullanma tarihi geçmiş.');
      expect(hata('13/27'), 'Ay 01 ile 12 arasında olmalıdır.');
      expect(hata('00/27'), 'Ay 01 ile 12 arasında olmalıdır.');
      expect(hata('1/27'), 'Son kullanma tarihini AA/YY biçiminde girin.');
      expect(hata('99/99'), 'Ay 01 ile 12 arasında olmalıdır.');
      expect(hata('12/99'), 'Son kullanma tarihi geçersiz.');
    });
  });

  test('CVV ve kart sahibi', () {
    expect(KartDogrulama.cvvHatasi('123'), isNull);
    expect(KartDogrulama.cvvHatasi('12'), isNotNull);
    expect(KartDogrulama.cvvHatasi('12a'), isNotNull);

    expect(KartDogrulama.kartSahibiHatasi('Ayşe Yılmaz'), isNull);
    expect(KartDogrulama.kartSahibiHatasi('Ayşe'), 'Ad ve soyadı girin.');
    expect(KartDogrulama.kartSahibiHatasi('Ayşe 2'), isNotNull);
    expect(KartDogrulama.kartSahibiHatasi('  '), 'Kart üzerindeki adı girin.');
  });

  test('sunucuya yalnızca son 4 hane gider', () {
    expect(KartDogrulama.sonDortHane('4242 4242 4242 1234'), '1234');
    expect(KartDogrulama.maskeli('1234'), '**** **** **** 1234');
  });

  group('Biçimleyiciler', () {
    TextEditingValue yaz(TextInputFormatter b, String metin, [int? imlec]) =>
        b.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: metin,
            selection: TextSelection.collapsed(offset: imlec ?? metin.length),
          ),
        );

    test('kart numarası 4\'erli gruplanır, 16 haneden fazlası alınmaz', () {
      final b = KartNumarasiBicimleyici();
      expect(yaz(b, '4242').text, '4242');
      expect(yaz(b, '42424').text, '4242 4');
      expect(yaz(b, '4242a4242-4242 42421111').text, '4242 4242 4242 4242');

      final sonuc = yaz(b, '424242');
      expect(sonuc.selection.baseOffset, sonuc.text.length);
    });

    test('ortadan hane silinince imleç yerinde kalır', () {
      // "4242 4242" metninde 6. haneden sonra (imleç 7'de) bir hane silindi
      final b = KartNumarasiBicimleyici();
      final sonuc = yaz(b, '4242 422', 6);
      expect(sonuc.text, '4242 422');
      expect(sonuc.selection.baseOffset, 6);
    });

    test('son kullanma tarihine "/" kendiliğinden eklenir', () {
      final b = SonKullanmaBicimleyici();
      expect(yaz(b, '1').text, '1');
      expect(yaz(b, '12').text, '12');
      expect(yaz(b, '123').text, '12/3');
      expect(yaz(b, '12/345').text, '12/34');
    });
  });
}
