import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const SuBiletApp());

class SuBiletApp extends StatelessWidget {
  const SuBiletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ŞuBilet',
      debugShowCheckedModeBanner: false,
      // Takvim ve diyalog gibi hazır bileşenler Türkçe görünsün
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const SeferAramaSayfasi(),
    );
  }
}

class SeferAramaSayfasi extends StatefulWidget {
  const SeferAramaSayfasi({super.key});

  @override
  State<SeferAramaSayfasi> createState() => _SeferAramaSayfasiState();
}

class _SeferAramaSayfasiState extends State<SeferAramaSayfasi> {
  // 2. haftada 81 ilin tamamı DropdownButton ile seçilebilecek
  static const _sehirler = [
    'Adana',
    'Ankara',
    'Antalya',
    'Bursa',
    'Eskişehir',
    'İstanbul',
    'İzmir',
    'Konya',
    'Samsun',
    'Trabzon',
  ];

  String _kalkis = 'Ankara';
  String _varis = 'İstanbul';

  // Başlangıçta bugünün tarihi
  DateTime _secilenTarih = DateTime.now();
  String _secilenEtiket = 'Bugün';

  void _sehirleriDegistir() {
    setState(() {
      final temp = _kalkis;
      _kalkis = _varis;
      _varis = temp;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kalkış ve varış noktaları yer değiştirdi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Alttan açılan listeden kalkış ya da varış şehrini seçtirir
  Future<void> _sehirSec({required bool kalkisMi}) async {
    final mevcut = kalkisMi ? _kalkis : _varis;
    final secilen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                kalkisMi ? 'Nereden?' : 'Nereye?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final sehir in _sehirler)
              ListTile(
                title: Text(sehir),
                trailing: sehir == mevcut
                    ? const Icon(Icons.check, color: Colors.indigo)
                    : null,
                onTap: () => Navigator.pop(context, sehir),
              ),
          ],
        ),
      ),
    );
    if (secilen == null || !mounted) return;

    setState(() {
      if (kalkisMi) {
        _kalkis = secilen;
      } else {
        _varis = secilen;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${kalkisMi ? 'Kalkış' : 'Varış'} noktası $secilen olarak seçildi.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Tarihi gün sayısı ekleyerek güncelleyen fonksiyon
  void _tarihAyarla(int gunEkle, String etiket) {
    setState(() {
      _secilenTarih = DateTime.now().add(Duration(days: gunEkle));
      _secilenEtiket = etiket;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarih $etiket (${_secilenTarih.day}.${_secilenTarih.month}.${_secilenTarih.year}) olarak seçildi.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _seferAra() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_kalkis -> $_varis (${_secilenTarih.day}.${_secilenTarih.month}.${_secilenTarih.year}) için seferler aranıyor...',
        ),
        backgroundColor: Colors.indigo,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ŞuBilet - Otobüs Bileti'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Kalkış Noktası
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.indigo),
                        title: const Text('Kalkış Noktası'),
                        onTap: () => _sehirSec(kalkisMi: true),
                        subtitle: Text(
                          _kalkis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.swap_vert, color: Colors.indigo),
                          tooltip: 'Yön Değiştir',
                          onPressed: _sehirleriDegistir,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Varış Noktası
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.flag, color: Colors.indigo),
                        title: const Text('Varış Noktası'),
                        onTap: () => _sehirSec(kalkisMi: false),
                        subtitle: Text(
                          _varis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tarih Seçim Butonları (Bugün / Yarın)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.today),
                            label: const Text('Bugün'),
                            style: _secilenEtiket == 'Bugün'
                                ? OutlinedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade50,
                              side: const BorderSide(color: Colors.indigo, width: 2),
                            )
                                : null,
                            onPressed: () => _tarihAyarla(0, 'Bugün'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.wb_sunny_outlined),
                            label: const Text('Yarın'),
                            style: _secilenEtiket == 'Yarın'
                                ? OutlinedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade50,
                              side: const BorderSide(color: Colors.indigo, width: 2),
                            )
                                : null,
                            onPressed: () => _tarihAyarla(1, 'Yarın'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Seçilen Tarihin Ekranda Gösterildiği Kısım
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            'Seyahat Tarihi: ${_secilenTarih.day}.${_secilenTarih.month}.${_secilenTarih.year} ($_secilenEtiket)',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sefer Ara Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Otobüs Bileti Bul', style: TextStyle(fontSize: 16)),
                        onPressed: _seferAra,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}