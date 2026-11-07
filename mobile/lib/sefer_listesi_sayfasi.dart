import 'package:flutter/material.dart';
import 'models/enumlar.dart';
import 'models/sefer.dart';

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
          final sefer = seferler[index];
          final saat =
              "${sefer.kalkisZamani.hour.toString().padLeft(2, '0')}:${sefer.kalkisZamani.minute.toString().padLeft(2, '0')}";

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sefer.firmaAdi,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kalkış: $saat | Düzen: ${sefer.koltukDuzeni.gorunenAd}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  '${sefer.fiyat.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}