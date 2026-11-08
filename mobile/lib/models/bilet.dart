import 'enumlar.dart';

class Bilet {
  final int id;
  final String pnrKodu;
  final int seferId;
  final String kullaniciId;
  final int odemeId;
  final int koltukNo;
  final String yolcuAd;
  final String yolcuSoyad;
  final String tcKimlikNo;
  final Cinsiyet cinsiyet;
  final double ucret;
  final BiletDurumu durum;
  final DateTime satisTarihi;

  Bilet({
    required this.id,
    required this.pnrKodu,
    required this.seferId,
    required this.kullaniciId,
    required this.odemeId,
    required this.koltukNo,
    required this.yolcuAd,
    required this.yolcuSoyad,
    required this.tcKimlikNo,
    required this.cinsiyet,
    required this.ucret,
    this.durum = BiletDurumu.aktif,
    required this.satisTarihi,
  });
}