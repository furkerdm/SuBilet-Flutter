import 'package:flutter/material.dart';

import 'models/enumlar.dart';
import 'models/koltuk_plani.dart';
import 'models/sefer.dart';
import 'widgets/koltuk_dugmesi.dart';
import 'widgets/sefer_karti.dart';

class KoltukSecimiSayfasi extends StatefulWidget {
  /// Bir satın almada seçilebilecek en fazla koltuk (web ile aynı)
  static const enFazlaKoltuk = 5;

  final Sefer sefer;

  /// Otobüsün koltuk sayısı; verilmezse düzene göre örnek (2+1: 41, 2+2: 46)
  final int? koltukSayisi;

  /// Satılmış koltuklar (koltuk no → yolcunun cinsiyeti). Verilmezse örnek
  /// veri kullanılır; 7. haftada sunucudan gelecek.
  final Map<int, Cinsiyet>? doluKoltuklar;

  const KoltukSecimiSayfasi({
    super.key,
    required this.sefer,
    this.koltukSayisi,
    this.doluKoltuklar,
  });

  @override
  State<KoltukSecimiSayfasi> createState() => _KoltukSecimiSayfasiState();
}

class _KoltukSecimiSayfasiState extends State<KoltukSecimiSayfasi> {
  late final KoltukPlani _plan = KoltukPlani(
    widget.sefer.koltukDuzeni,
    widget.koltukSayisi ??
        (widget.sefer.koltukDuzeni == KoltukDuzeni.ikiArtiBir ? 41 : 46),
  );

  late final Map<int, Cinsiyet> _doluKoltuklar =
      widget.doluKoltuklar ?? _ornekDoluKoltuklar();

  /// Kullanıcının seçtiği koltuklar: koltuk no → yolcunun cinsiyeti
  final Map<int, Cinsiyet> _secimler = {};

  List<int> get _seciliKoltuklar => _secimler.keys.toList()..sort();

  // API bağlanana kadar her sefer için aynı kalan örnek dolu koltuklar
  Map<int, Cinsiyet> _ornekDoluKoltuklar() {
    final id = widget.sefer.id;
    return {
      for (var no = 1; no <= _plan.koltukSayisi; no++)
        if ((no * 7 + id * 3) % 5 < 2)
          no: (no + id).isEven ? Cinsiyet.erkek : Cinsiyet.kadin,
    };
  }

  Future<void> _koltugaDokun(int no) async {
    // Seçili koltuğa yeniden dokunulunca seçim kaldırılır
    if (_secimler.containsKey(no)) {
      setState(() => _secimler.remove(no));
      return;
    }

    if (_secimler.length >= KoltukSecimiSayfasi.enFazlaKoltuk) {
      _bildir(
        'Bir seferde en fazla ${KoltukSecimiSayfasi.enFazlaKoltuk} '
        'koltuk seçebilirsiniz.',
      );
      return;
    }

    final cinsiyet = await _cinsiyetSor(no);
    if (cinsiyet == null || !mounted) return;

    // Yan koltuk kuralı: yan koltuk başka cinsiyetten bir yolcuya satılmışsa
    // bu koltuk seçilemez
    final yan = _plan.yanKoltuk(no);
    final yandaki = yan == null ? null : _doluKoltuklar[yan];
    if (yan != null && yandaki != null && yandaki != cinsiyet) {
      await _kuralUyarisi(no, yan, yandaki);
      return;
    }

    setState(() => _secimler[no] = cinsiyet);
  }

  Future<Cinsiyet?> _cinsiyetSor(int no) {
    return showDialog<Cinsiyet>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('$no numaralı koltuk'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Bu koltukta seyahat edecek yolcunun cinsiyetini seçin.',
            ),
          ),
          for (final cinsiyet in Cinsiyet.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, cinsiyet),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: KoltukRenkleri.cinsiyet(cinsiyet),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cinsiyet.gorunenAd,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _kuralUyarisi(int no, int yan, Cinsiyet yandaki) {
    final yolcu = yandaki.gorunenAd.toLowerCase();
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Bu koltuk seçilemez'),
        content: Text(
          'Yanındaki $yan numaralı koltukta $yolcu yolcu seyahat ediyor. '
          '$no numaralı koltuğu yalnızca $yolcu yolcu alabilir; '
          'farklı bir koltuk seçin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _bildir(String mesaj) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mesaj), duration: const Duration(seconds: 2)),
      );
  }

  void _devamEt() {
    // Yolcu bilgileri formu 5. haftada bu adıma bağlanacak
    _bildir(
      'Koltuk ${_seciliKoltuklar.join(', ')} seçildi. '
      'Yolcu bilgileri adımı 5. haftada eklenecek.',
    );
  }

  // Koltuk renklerinin açıklaması
  Widget _lejant() {
    Widget oge(Color zemin, String metin, {Color? kenar}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: zemin,
              border: Border.all(color: kenar ?? zemin, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(metin, style: const TextStyle(fontSize: 13)),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          oge(Colors.white, 'Boş', kenar: Colors.blueGrey.shade200),
          oge(KoltukRenkleri.secili, 'Seçtiğiniz'),
          oge(KoltukRenkleri.erkek, 'Dolu (erkek)'),
          oge(KoltukRenkleri.kadin, 'Dolu (kadın)'),
        ],
      ),
    );
  }

  Widget _koltuk(int? no) {
    if (no == null) {
      return const SizedBox.square(dimension: KoltukDugmesi.boyut);
    }
    return KoltukDugmesi(
      key: ValueKey('koltuk-$no'),
      no: no,
      doluCinsiyet: _doluKoltuklar[no],
      seciliCinsiyet: _secimler[no],
      onTap: () => _koltugaDokun(no),
    );
  }

  // Otobüsün üstten görünüşü: ön tarafı yukarıda, koridor ortada
  Widget _otobus() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.blueGrey.shade100, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      // Gövde koltuk sıraları kadar geniş olsun; "Ön" satırı ve çizgi ona uyar
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_upward, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('Ön', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const Divider(height: 8),
            for (final sira in _plan.siralar)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  for (final no in sira.sol) _koltuk(no),
                  const SizedBox(width: 20), // koridor
                  for (final no in sira.sag) _koltuk(no),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Ekranın altındaki seçim özeti: seçilen koltuklar, toplam ve devam düğmesi
  Widget _secimCubugu() {
    final renkler = Theme.of(context).colorScheme;
    final secili = _seciliKoltuklar;
    final toplam = secili.length * widget.sefer.fiyat;

    return Material(
      elevation: 8,
      color: renkler.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (secili.isEmpty)
                Text(
                  'Haritadan en fazla ${KoltukSecimiSayfasi.enFazlaKoltuk} '
                  'koltuk seçebilirsiniz.',
                  style: TextStyle(color: renkler.onSurfaceVariant),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final no in secili)
                      InputChip(
                        label: Text('$no · ${_secimler[no]!.gorunenAd}'),
                        onDeleted: () => setState(() => _secimler.remove(no)),
                        deleteButtonTooltipMessage: 'Kaldır',
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam',
                          style: TextStyle(color: renkler.onSurfaceVariant),
                        ),
                        Text(
                          '${toplam.toStringAsFixed(0)} TL',
                          key: const ValueKey('toplamTutar'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: secili.isEmpty ? null : _devamEt,
                    child: const Text('Devam Et'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sefer = widget.sefer;

    return Scaffold(
      appBar: AppBar(
        title: Text('${sefer.kalkisSehirAdi} → ${sefer.varisSehirAdi}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          SeferKarti(sefer: sefer),
          _lejant(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: _otobus()),
          ),
        ],
      ),
      bottomNavigationBar: _secimCubugu(),
    );
  }
}
