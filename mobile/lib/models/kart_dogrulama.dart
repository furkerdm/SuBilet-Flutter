/// Simüle ödeme ekranındaki kart alanlarının doğrulaması.
///
/// Gerçek bir ödeme yapılmaz. Kart numarası yalnızca biçim ve Luhn
/// algoritmasıyla kontrol edilir; sunucuya kartın son 4 hanesi dışında hiçbir
/// kart bilgisi gönderilmez.
class KartDogrulama {
  static const kartNumarasiUzunlugu = 16;

  /// Boşluk ve tireleri atıp yalnızca rakamları bırakır
  static String rakamlar(String metin) => metin.replaceAll(RegExp(r'\D'), '');

  /// Luhn algoritması: sağdan başlayarak her ikinci hane iki katına çıkarılır
  /// (9'dan büyükse 9 çıkarılır), tüm haneler toplanır; toplam 10'a tam
  /// bölünüyorsa numara geçerlidir.
  static bool luhnGecerliMi(String numara) {
    final haneler = rakamlar(numara);
    if (haneler.isEmpty) return false;

    var toplam = 0;
    var ikiKati = false;
    for (var i = haneler.length - 1; i >= 0; i--) {
      var hane = haneler.codeUnitAt(i) - 48;
      if (ikiKati) {
        hane *= 2;
        if (hane > 9) hane -= 9;
      }
      toplam += hane;
      ikiKati = !ikiKati;
    }
    return toplam % 10 == 0;
  }

  static String? kartNumarasiHatasi(String? metin) {
    final haneler = rakamlar(metin ?? '');
    if (haneler.isEmpty) return 'Kart numarasını girin.';
    if (haneler.length != kartNumarasiUzunlugu) {
      return 'Kart numarası $kartNumarasiUzunlugu haneli olmalıdır.';
    }
    if (!luhnGecerliMi(haneler)) return 'Kart numarası geçersiz.';
    return null;
  }

  /// "AA/YY" biçimindeki son kullanma tarihi. Kart, yazan ayın sonuna kadar
  /// geçerlidir; bu yüzden içinde bulunulan ay kabul edilir.
  static String? sonKullanmaHatasi(String? metin, {DateTime? simdi}) {
    final eslesme = RegExp(r'^(\d{2})/(\d{2})$')
        .firstMatch(metin?.trim() ?? '');
    if (eslesme == null) return 'Son kullanma tarihini AA/YY biçiminde girin.';

    final ay = int.parse(eslesme.group(1)!);
    final yil = 2000 + int.parse(eslesme.group(2)!);
    if (ay < 1 || ay > 12) return 'Ay 01 ile 12 arasında olmalıdır.';

    final bugun = simdi ?? DateTime.now();
    final kartAyi = yil * 12 + ay;
    final buAy = bugun.year * 12 + bugun.month;
    if (kartAyi < buAy) return 'Kartın son kullanma tarihi geçmiş.';
    if (yil > bugun.year + 20) return 'Son kullanma tarihi geçersiz.';
    return null;
  }

  static String? cvvHatasi(String? metin) {
    if (!RegExp(r'^\d{3}$').hasMatch(metin?.trim() ?? '')) {
      return 'Kartın arkasındaki 3 haneli kodu girin.';
    }
    return null;
  }

  static String? kartSahibiHatasi(String? metin) {
    final ad = (metin ?? '').trim();
    if (ad.isEmpty) return 'Kart üzerindeki adı girin.';
    if (!RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ ]+$').hasMatch(ad)) {
      return 'Ad yalnızca harflerden oluşmalıdır.';
    }
    if (ad.split(RegExp(r'\s+')).length < 2) return 'Ad ve soyadı girin.';
    return null;
  }

  /// Sunucuya gönderilecek tek kart bilgisi
  static String sonDortHane(String numara) {
    final haneler = rakamlar(numara);
    return haneler.substring(haneler.length - 4);
  }

  /// **** **** **** 1234 biçiminde maskelenmiş numara
  static String maskeli(String sonDortHane) => '**** **** **** $sonDortHane';
}
