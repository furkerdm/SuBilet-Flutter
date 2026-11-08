import 'package:flutter/material.dart';
import 'models/enumlar.dart';
import 'models/sefer.dart';
import 'widgets/sefer_karti.dart';

class SeferListesiSayfasi extends StatelessWidget {
  final String kalkisSehir;
  final String varisSehir;
  final DateTime tarih;

  const SeferListesiSayfasi({
    super.key,
    required this.kalkisSehir,
    required this.varisSehir,
    required this.tarih,
  });

  List<Sefer> _ornekSeferleriUret() {
    return [
      Sefer(
        id: 1,
        firmaId: 1,
        firmaAdi: 'Kamil Koç',
        otobusId: 10,
        koltukDuzeni: KoltukDuzeni.ikiArtiBir,
        kalkisSehirId: 6,
        kalkisSehirAdi: kalkisSehir,
        varisSehirId: 34,
        varisSehirAdi: varisSehir,
        kalkisZamani: DateTime(tarih.year, tarih.month, tarih.day, 9, 30),
        tahminiVarisZamani: DateTime(tarih.year, tarih.month, tarih.day, 15, 0),
        fiyat: 450.0,
        durum: SeferDurumu.aktif,
      ),
      Sefer(
        id: 2,
        firmaId: 2,
        firmaAdi: 'Pamukkale Turizm',
        otobusId: 11,
        koltukDuzeni: KoltukDuzeni.ikiArtiIki,
        kalkisSehirId: 6,
        kalkisSehirAdi: kalkisSehir,
        varisSehirId: 34,
        varisSehirAdi: varisSehir,
        kalkisZamani: DateTime(tarih.year, tarih.month, tarih.day, 13, 0),
        tahminiVarisZamani: DateTime(tarih.year, tarih.month, tarih.day, 18, 30),
        fiyat: 480.0,
        durum: SeferDurumu.aktif,
      ),
      Sefer(
        id: 3,
        firmaId: 3,
        firmaAdi: 'Metro Turizm',
        otobusId: 12,
        koltukDuzeni: KoltukDuzeni.ikiArtiBir,
        kalkisSehirId: 6,
        kalkisSehirAdi: kalkisSehir,
        varisSehirId: 34,
        varisSehirAdi: varisSehir,
        kalkisZamani: DateTime(tarih.year, tarih.month, tarih.day, 17, 45),
        tahminiVarisZamani: DateTime(tarih.year, tarih.month, tarih.day, 23, 15),
        fiyat: 420.0,
        durum: SeferDurumu.aktif,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final seferler = _ornekSeferleriUret();

    return Scaffold(
      appBar: AppBar(
        title: Text('$kalkisSehir → $varisSehir'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: seferler.length,
        itemBuilder: (context, index) {
          return SeferKarti(sefer: seferler[index]);
        },
      ),
    );
  }
}