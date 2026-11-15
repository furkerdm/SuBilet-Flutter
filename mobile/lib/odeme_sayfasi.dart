import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/enumlar.dart';
import 'models/kart_dogrulama.dart';
import 'models/odeme_sonucu.dart';
import 'models/sefer.dart';
import 'widgets/bilet_onay_diyalogu.dart';
import 'widgets/kart_bicimleyicileri.dart';
import 'widgets/koltuk_dugmesi.dart';
import 'widgets/sefer_karti.dart';

/// Kredi kartı simülasyonu. Gerçek ödeme alınmaz; kart bilgileri yalnızca
/// biçim ve Luhn ile kontrol edilir. Ödemeden sonra kart alanları temizlenir,
/// elde yalnızca kartın son 4 hanesi kalır (7. haftada sunucuya giden de bu).
class OdemeSayfasi extends StatefulWidget {
  final Sefer sefer;

  /// Seçilen koltuklar: koltuk no → yolcunun cinsiyeti
  final Map<int, Cinsiyet> koltuklar;

  /// GEÇİCİ: PNR 7. haftada sunucudan gelecek. Testlerde sabit kod verilir.
  final String Function() pnrUret;

  /// Ödemenin "işleniyor" görünümünde bekleme süresi
  final Duration islemSuresi;

  /// Son kullanma tarihi kontrolünde bugünün yerine geçer (testler için)
  final DateTime? simdi;

  const OdemeSayfasi({
    super.key,
    required this.sefer,
    required this.koltuklar,
    this.pnrUret = PnrUretici.uret,
    this.islemSuresi = const Duration(milliseconds: 1200),
    this.simdi,
  });

  @override
  State<OdemeSayfasi> createState() => _OdemeSayfasiState();
}

class _OdemeSayfasiState extends State<OdemeSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _kartSahibi = TextEditingController();
  final _kartNumarasi = TextEditingController();
  final _sonKullanma = TextEditingController();
  final _cvv = TextEditingController();

  bool _isleniyor = false;

  List<int> get _koltukNolari => widget.koltuklar.keys.toList()..sort();

  double get _toplam => widget.koltuklar.length * widget.sefer.fiyat;

  @override
  void dispose() {
    _kartSahibi.dispose();
    _kartNumarasi.dispose();
    _sonKullanma.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _odemeYap() async {
    FocusScope.of(context).unfocus();
    if (!_formAnahtari.currentState!.validate()) return;

    setState(() => _isleniyor = true);
    await Future<void>.delayed(widget.islemSuresi);
    if (!mounted) return;

    // Kart bilgilerinden yalnızca son 4 hane tutulur
    final sonDortHane = KartDogrulama.sonDortHane(_kartNumarasi.text);
    final pnrler = <String>{};
    final sonuc = OdemeSonucu(
      sefer: widget.sefer,
      kartSonDortHane: sonDortHane,
      odemeTarihi: DateTime.now(),
      biletler: [
        for (final no in _koltukNolari)
          BiletOzeti(
            koltukNo: no,
            cinsiyet: widget.koltuklar[no]!,
            pnrKodu: _benzersizPnr(pnrler),
          ),
      ],
    );

    _kartSahibi.clear();
    _kartNumarasi.clear();
    _sonKullanma.clear();
    _cvv.clear();
    setState(() => _isleniyor = false);

    await BiletOnayDiyalogu.goster(
      context,
      sonuc,
      // Satın alma bitti; koltuk seçimi ve sefer listesine geri dönülmez
      onTamam: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }

  // Aynı satın almadaki biletlerin PNR kodları birbirinden farklı olmalı
  String _benzersizPnr(Set<String> kullanilanlar) {
    var pnr = widget.pnrUret();
    for (var deneme = 0; !kullanilanlar.add(pnr) && deneme < 20; deneme++) {
      pnr = widget.pnrUret();
    }
    return pnr;
  }

  Widget _koltukOzeti() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Koltuklar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final no in _koltukNolari)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: KoltukRenkleri.cinsiyet(
                        widget.koltuklar[no]!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Koltuk $no · ${widget.koltuklar[no]!.gorunenAd}'),
                    const Spacer(),
                    Text('${widget.sefer.fiyat.toStringAsFixed(0)} TL'),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              children: [
                const Text(
                  'Toplam',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_toplam.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartFormu() {
    final renkler = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Form(
        key: _formAnahtari,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(
              'Kart Bilgileri',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 18, color: renkler.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu bir ödeme simülasyonudur; kartınızdan para çekilmez. '
                    'Kart numaranız saklanmaz, yalnızca son 4 hanesi kaydedilir.',
                    style: TextStyle(
                      fontSize: 13,
                      color: renkler.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              key: const ValueKey('kartSahibi'),
              controller: _kartSahibi,
              enabled: !_isleniyor,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.creditCardName],
              decoration: const InputDecoration(
                labelText: 'Kart üzerindeki ad soyad',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: KartDogrulama.kartSahibiHatasi,
            ),
            TextFormField(
              key: const ValueKey('kartNumarasi'),
              controller: _kartNumarasi,
              enabled: !_isleniyor,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.creditCardNumber],
              inputFormatters: [KartNumarasiBicimleyici()],
              decoration: const InputDecoration(
                labelText: 'Kart numarası',
                hintText: '0000 0000 0000 0000',
                helperText: 'Deneme için: 4242 4242 4242 4242',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              validator: KartDogrulama.kartNumarasiHatasi,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('sonKullanma'),
                    controller: _sonKullanma,
                    enabled: !_isleniyor,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.creditCardExpirationDate,
                    ],
                    inputFormatters: [SonKullanmaBicimleyici()],
                    decoration: const InputDecoration(
                      labelText: 'Son kullanma',
                      hintText: 'AA/YY',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (metin) => KartDogrulama.sonKullanmaHatasi(
                      metin,
                      simdi: widget.simdi,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('cvv'),
                    controller: _cvv,
                    enabled: !_isleniyor,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofillHints: const [AutofillHints.creditCardSecurityCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onFieldSubmitted: (_) => _odemeYap(),
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '000',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: KartDogrulama.cvvHatasi,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _odemeCubugu() {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: FilledButton(
            onPressed: _isleniyor ? null : _odemeYap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: _isleniyor
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(width: 12),
                      Text('Ödeme işleniyor...'),
                    ],
                  )
                : Text('${_toplam.toStringAsFixed(0)} TL Öde'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Ödeme işlenirken geri dönülmesin
      canPop: !_isleniyor,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ödeme'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        // Klavye açılınca alanlar taşmasın, kaydırılabilsin
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 6, bottom: 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SeferKarti(sefer: widget.sefer),
              _koltukOzeti(),
              _kartFormu(),
            ],
          ),
        ),
        bottomNavigationBar: _odemeCubugu(),
      ),
    );
  }
}
