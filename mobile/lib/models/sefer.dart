import 'enumlar.dart';

class Sefer {
  final int id;
  final int firmaId;
  final String firmaAdi;
  final String? firmaLogoUrl;
  final int otobusId;
  final KoltukDuzeni koltukDuzeni;
  final int kalkisSehirId;
  final String kalkisSehirAdi;
  final int varisSehirId;
  final String varisSehirAdi;
  final DateTime kalkisZamani;
  final DateTime tahminiVarisZamani;
  final double fiyat;
  final SeferDurumu durum;

  Sefer({
    required this.id,
    required this.firmaId,
    required this.firmaAdi,
    this.firmaLogoUrl,
    required this.otobusId,
    required this.koltukDuzeni,
    required this.kalkisSehirId,
    required this.kalkisSehirAdi,
    required this.varisSehirId,
    required this.varisSehirAdi,
    required this.kalkisZamani,
    required this.tahminiVarisZamani,
    required this.fiyat,
    this.durum = SeferDurumu.aktif,
  });
}