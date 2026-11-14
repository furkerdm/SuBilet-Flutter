import 'package:flutter/material.dart';
import 'koltuk_secimi_sayfasi.dart';
import 'models/enumlar.dart';
import 'models/sefer.dart';
import 'widgets/sefer_karti.dart';

// Sefer listesindeki sıralama seçenekleri
enum SeferSiralamasi {
  kalkisSaati('Kalkış saati'),
  fiyatArtan('En düşük fiyat'),
  fiyatAzalan('En yüksek fiyat');

  final String gorunenAd;
  const SeferSiralamasi(this.gorunenAd);
}

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
  SeferSiralamasi _siralama = SeferSiralamasi.kalkisSaati;

  // null ise tüm firmalar gösterilir
  int? _seciliFirmaId;

  // Listede seferi olan firmalar (firma no → ad), ada göre sıralı
  late final List<MapEntry<int, String>> _firmalar = {
    for (final s in _seferler) s.firmaId: s.firmaAdi,
  }.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

  // Seçili firmaya ve sıralamaya göre ekranda gösterilecek seferler
  List<Sefer> get _gosterilenSeferler {
    final liste = _seciliFirmaId == null
        ? [..._seferler]
        : _seferler.where((s) => s.firmaId == _seciliFirmaId).toList();
    liste.sort((a, b) {
      final sonuc = switch (_siralama) {
        SeferSiralamasi.kalkisSaati => 0,
        SeferSiralamasi.fiyatArtan => a.fiyat.compareTo(b.fiyat),
        SeferSiralamasi.fiyatAzalan => b.fiyat.compareTo(a.fiyat),
      };
      // Eşitlikte erken kalkan sefer önce gelir
      return sonuc != 0 ? sonuc : a.kalkisZamani.compareTo(b.kalkisZamani);
    });
    return liste;
  }

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

  // Firma filtresi; tek firmalı listede gösterilmez
  Widget _firmaFiltresi() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tüm firmalar'),
            selected: _seciliFirmaId == null,
            onSelected: (_) => setState(() => _seciliFirmaId = null),
          ),
          for (final firma in _firmalar) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(firma.value),
              selected: _seciliFirmaId == firma.key,
              // Seçili firmaya yeniden dokunulursa filtre kaldırılır
              onSelected: (secildi) =>
                  setState(() => _seciliFirmaId = secildi ? firma.key : null),
            ),
          ],
        ],
      ),
    );
  }

  // Sefer sayısı ve sıralama seçimi
  Widget _siralamaCubugu(int seferSayisi) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$seferSayisi sefer',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.sort, size: 20),
          const SizedBox(width: 8),
          DropdownButton<SeferSiralamasi>(
            value: _siralama,
            underline: const SizedBox.shrink(),
            items: [
              for (final secenek in SeferSiralamasi.values)
                DropdownMenuItem(
                  value: secenek,
                  child: Text(secenek.gorunenAd),
                ),
            ],
            onChanged: (secenek) {
              if (secenek == null) return;
              setState(() => _siralama = secenek);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seferler = _gosterilenSeferler;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.kalkisSehir} → ${widget.varisSehir}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _seferler.isEmpty
          ? _bosDurum()
          : Column(
              children: [
                if (_firmalar.length > 1) _firmaFiltresi(),
                _siralamaCubugu(seferler.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: seferler.length,
                    itemBuilder: (context, index) {
                      final sefer = seferler[index];
                      return SeferKarti(
                        sefer: sefer,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                KoltukSecimiSayfasi(sefer: sefer),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
