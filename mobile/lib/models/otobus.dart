import 'enumlar.dart';

class Otobus {
  final int id;
  final int? firmaId;
  final String plaka;
  final KoltukDuzeni koltukDuzeni;
  final int koltukSayisi;
  final List<String> ozellikler;

  Otobus({
    required this.id,
    this.firmaId,
    required this.plaka,
    required this.koltukDuzeni,
    required this.koltukSayisi,
    this.ozellikler = const [],
  });
}