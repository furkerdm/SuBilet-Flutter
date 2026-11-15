import 'dart:math';

import 'enumlar.dart';
import 'sefer.dart';

/// Ödemesi yapılan tek bir koltuğun bileti
class BiletOzeti {
  final int koltukNo;
  final Cinsiyet cinsiyet;
  final String pnrKodu;

  const BiletOzeti({
    required this.koltukNo,
    required this.cinsiyet,
    required this.pnrKodu,
  });
}

/// Simüle ödemenin sonucu; bilet onay diyaloğunda gösterilir.
/// Kart bilgilerinden yalnızca son 4 hane tutulur.
class OdemeSonucu {
  final Sefer sefer;
  final List<BiletOzeti> biletler;
  final String kartSonDortHane;
  final DateTime odemeTarihi;

  const OdemeSonucu({
    required this.sefer,
    required this.biletler,
    required this.kartSonDortHane,
    required this.odemeTarihi,
  });

  double get toplamTutar => biletler.length * sefer.fiyat;
}

/// GEÇİCİ: 7. haftada PNR kodunu sunucu üretecek (POST /api/biletler) ve
/// bu sınıf kaldırılacak.
///
/// Veritabanında her biletin kendi PNR kodu vardır (benzersiz, en fazla 8
/// karakter). Karışmasın diye 0/O ve 1/I gibi benzeyen karakterler ile Türk
/// alfabesinde olmayan Q, W, X kullanılmaz.
class PnrUretici {
  static const uzunluk = 6;
  static const karakterler = 'ABCDEFGHJKLMNPRSTUVYZ23456789';

  static final _rastgele = Random.secure();

  static String uret() => String.fromCharCodes(
    List.generate(
      uzunluk,
      (_) => karakterler.codeUnitAt(_rastgele.nextInt(karakterler.length)),
    ),
  );
}
