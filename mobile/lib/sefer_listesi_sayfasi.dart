import 'package:flutter/material.dart';
import 'models/enumlar.dart';
import 'models/sefer.dart';
import 'widgets/sefer_karti.dart';

class SeferListesiSayfasi extends StatefulWidget {
  final String kalkisSehir;
  final String varisSehir;
  final DateTime tarih;

  // Verilmezse örnek seferler gösterilir (6. haftada API'den gelecek)
  final List<Sefer>? seferler;

  const SeferListesiSayfasi({
    super.key,
    required this.kalkisSehir,
    required this.varisSehir,
    required this.tarih,
    this.seferler,
  });

  @override
  State<SeferListesiSayfasi> createState() => _SeferListesiSayfasiState();
}

class _SeferListesiSayfasiState extends State<SeferListesiSayfasi> {
  late final List<Sefer> _seferler = widget.seferler ?? _ornekSeferleriUret();

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
      final tarih = widget.tarih;
      final kalkis = DateTime(tarih.year, tarih.month, tarih.day, saat, dakika);
      return Sefer(
        id: id,
        firmaId: firmaId,
        firmaAdi: firmaAdi,
        otobusId: 10 + id,
        koltukDuzeni: koltukDuzeni,
        kalkisSehirId: 6,
        kalkisSehirAdi: widget.kalkisSehir,
        varisSehirId: 34,
        varisSehirAdi: widget.varisSehir,
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

  // Aramaya uygun sefer yoksa gösterilen ekran
  Widget _bosDurum() {
    final renkler = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 72,
              color: renkler.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Sefer bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Seçtiğiniz tarihte bu güzergâhta sefer yok. '
              'Farklı bir tarih ya da güzergâh deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: renkler.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.search),
              label: const Text('Aramayı Değiştir'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.kalkisSehir} → ${widget.varisSehir}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _seferler.isEmpty
          ? _bosDurum()
          : ListView.builder(
              itemCount: _seferler.length,
              itemBuilder: (context, index) {
                return SeferKarti(sefer: _seferler[index]);
              },
            ),
    );
  }
}
