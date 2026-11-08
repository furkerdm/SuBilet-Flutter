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

  // API bağlanana kadar kullanılan örnek veri; firmalar web projesindeki
  // başlangıç verisiyle aynıdır.
  List<Sefer> _ornekSeferleriUret() {
    Sefer sefer(
      int id,
      int firmaId,
      String firmaAdi,
      KoltukDuzeni koltukDuzeni,
      int saat,
      int dakika,
      int sureDakika,
      double fiyat,
    ) {
      final kalkis = DateTime(tarih.year, tarih.month, tarih.day, saat, dakika);
      return Sefer(
        id: id,
        firmaId: firmaId,
        firmaAdi: firmaAdi,
        otobusId: 10 + id,
        koltukDuzeni: koltukDuzeni,
        kalkisSehirId: 6,
        kalkisSehirAdi: kalkisSehir,
        varisSehirId: 34,
        varisSehirAdi: varisSehir,
        kalkisZamani: kalkis,
        tahminiVarisZamani: kalkis.add(Duration(minutes: sureDakika)),
        fiyat: fiyat,
      );
    }

    const anadolu = 'Anadolu Ekspres';
    const ege = 'Ege Yıldızı Turizm';
    const bogazici = 'Boğaziçi Seyahat';
    const ikiArtiBir = KoltukDuzeni.ikiArtiBir;
    const ikiArtiIki = KoltukDuzeni.ikiArtiIki;

    // id, firma no ve adı, koltuk düzeni, kalkış saati ve dakikası, süre (dk), fiyat
    return [
      sefer(1, 1, anadolu, ikiArtiBir, 9, 30, 330, 450),
      sefer(2, 2, ege, ikiArtiIki, 13, 0, 330, 480),
      sefer(3, 3, bogazici, ikiArtiBir, 17, 45, 330, 420),
      sefer(4, 1, anadolu, ikiArtiIki, 7, 0, 360, 390),
      sefer(5, 2, ege, ikiArtiBir, 23, 30, 375, 510),
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