import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/kart_dogrulama.dart';
import '../models/odeme_sonucu.dart';
import 'koltuk_dugmesi.dart';

/// Ödeme sonrası gösterilen bilet onay ve özet diyaloğu. Her koltuğun PNR
/// kodu ayrı yazılır ve kopyalanabilir.
class BiletOnayDiyalogu extends StatelessWidget {
  final OdemeSonucu sonuc;

  /// "Ana Sayfaya Dön" düğmesine basılınca çalışır
  final VoidCallback onTamam;

  const BiletOnayDiyalogu({
    super.key,
    required this.sonuc,
    required this.onTamam,
  });

  /// Diyalog dışına dokunarak ya da geri tuşuyla kapatılamaz; kullanıcı PNR
  /// kodunu gördükten sonra düğmeyle çıkar.
  static Future<void> goster(
    BuildContext context,
    OdemeSonucu sonuc, {
    required VoidCallback onTamam,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: BiletOnayDiyalogu(sonuc: sonuc, onTamam: onTamam),
      ),
    );
  }

  static const _gunAdlari = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  // 20.11.2026 Cuma 09:30
  static String _tarihSaat(DateTime zaman) {
    String iki(int sayi) => sayi.toString().padLeft(2, '0');
    return '${iki(zaman.day)}.${iki(zaman.month)}.${zaman.year} '
        '${_gunAdlari[zaman.weekday - 1]} ${iki(zaman.hour)}:${iki(zaman.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final sefer = sonuc.sefer;
    final yaziStili = Theme.of(context).textTheme;
    final birden = sonuc.biletler.length > 1;

    return AlertDialog(
      icon: const Icon(
        Icons.check_circle_rounded,
        color: KoltukRenkleri.secili,
        size: 48,
      ),
      title: const Text('Ödeme başarılı'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              birden
                  ? 'Biletleriniz oluşturuldu. Her koltuğun PNR kodu ayrıdır; '
                        'biletinizi bu kodla sorgulayabilirsiniz.'
                  : 'Biletiniz oluşturuldu. Biletinizi PNR koduyla '
                        'sorgulayabilirsiniz.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${sefer.kalkisSehirAdi} → ${sefer.varisSehirAdi}',
              style: yaziStili.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(sefer.firmaAdi),
            Text(_tarihSaat(sefer.kalkisZamani)),
            const SizedBox(height: 12),
            for (final bilet in sonuc.biletler) _PnrSatiri(bilet: bilet),
            const Divider(height: 24),
            _bilgiSatiri(
              'Toplam',
              '${sonuc.toplamTutar.toStringAsFixed(0)} TL',
              kalin: true,
            ),
            const SizedBox(height: 4),
            _bilgiSatiri('Kart', KartDogrulama.maskeli(sonuc.kartSonDortHane)),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: onTamam, child: const Text('Ana Sayfaya Dön')),
      ],
    );
  }

  Widget _bilgiSatiri(String baslik, String deger, {bool kalin = false}) {
    final stil = TextStyle(fontWeight: kalin ? FontWeight.bold : null);
    // Dar ekranda ya da büyük yazı boyutunda değer alt satıra geçer, taşmaz
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: stil),
        const SizedBox(width: 12),
        Expanded(
          child: Text(deger, style: stil, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

/// Tek koltuğun PNR kodu ve kopyalama düğmesi
class _PnrSatiri extends StatefulWidget {
  final BiletOzeti bilet;

  const _PnrSatiri({required this.bilet});

  @override
  State<_PnrSatiri> createState() => _PnrSatiriState();
}

class _PnrSatiriState extends State<_PnrSatiri> {
  bool _kopyalandi = false;

  Future<void> _kopyala() async {
    await Clipboard.setData(ClipboardData(text: widget.bilet.pnrKodu));
    if (!mounted) return;
    setState(() => _kopyalandi = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _kopyalandi = false);
  }

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    final bilet = widget.bilet;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: renkler.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6,
            backgroundColor: KoltukRenkleri.cinsiyet(bilet.cinsiyet),
          ),
          const SizedBox(width: 10),
          // PNR koltuk bilgisinin altında durur; dar ekranda sıkışmaz
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koltuk ${bilet.koltukNo} · ${bilet.cinsiyet.gorunenAd}',
                  style: TextStyle(
                    fontSize: 13,
                    color: renkler.onSurfaceVariant,
                  ),
                ),
                Text(
                  bilet.pnrKodu,
                  key: ValueKey('pnr-${bilet.koltukNo}'),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: renkler.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _kopyala,
            tooltip: 'PNR kodunu kopyala',
            icon: Icon(_kopyalandi ? Icons.check : Icons.copy, size: 20),
          ),
        ],
      ),
    );
  }
}
