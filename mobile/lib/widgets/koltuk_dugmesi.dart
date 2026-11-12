import 'package:flutter/material.dart';

import '../models/enumlar.dart';

/// Koltuk haritasındaki renkler; web sitesindeki koltuk haritasıyla aynı
class KoltukRenkleri {
  static const erkek = Color(0xFF5B8FD6);
  static const kadin = Color(0xFFE5739C);
  static const secili = Color(0xFF2E9D5B);

  static Color cinsiyet(Cinsiyet cinsiyet) =>
      cinsiyet == Cinsiyet.kadin ? kadin : erkek;
}

/// Koltuk haritasındaki tek bir koltuk.
///
/// - Boş: beyaz, dokunulabilir
/// - Dolu: yolcunun cinsiyetine göre mavi (erkek) ya da pembe (kadın), dokunulamaz
/// - Seçili: yeşil; köşesinde seçilen cinsiyetin harfi (E / K) yazar
class KoltukDugmesi extends StatelessWidget {
  static const boyut = 44.0;

  final int no;

  /// Satılmış koltukta yolcunun cinsiyeti; boş koltukta null
  final Cinsiyet? doluCinsiyet;

  /// Kullanıcının bu koltuk için seçtiği cinsiyet; seçili değilse null
  final Cinsiyet? seciliCinsiyet;

  final VoidCallback? onTap;

  const KoltukDugmesi({
    super.key,
    required this.no,
    this.doluCinsiyet,
    this.seciliCinsiyet,
    this.onTap,
  });

  String get _durumMetni {
    if (doluCinsiyet != null) {
      return 'dolu (${doluCinsiyet!.gorunenAd.toLowerCase()} yolcu)';
    }
    if (seciliCinsiyet != null) {
      return 'seçildi (${seciliCinsiyet!.gorunenAd.toLowerCase()})';
    }
    return 'boş';
  }

  @override
  Widget build(BuildContext context) {
    final dolu = doluCinsiyet != null;
    final secili = seciliCinsiyet != null;
    final zemin = dolu
        ? KoltukRenkleri.cinsiyet(doluCinsiyet!)
        : secili
        ? KoltukRenkleri.secili
        : Colors.white;
    final kenar = dolu || secili ? zemin : Colors.blueGrey.shade200;
    final yazi = dolu || secili ? Colors.white : Colors.indigo.shade900;

    return Semantics(
      button: !dolu,
      selected: secili,
      label: '$no numaralı koltuk, $_durumMetni',
      excludeSemantics: true,
      child: SizedBox(
        width: boyut,
        height: boyut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: zemin,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: kenar, width: 1.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                    bottom: Radius.circular(6),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: dolu ? null : onTap,
                  child: Center(
                    child: Text(
                      '$no',
                      style: TextStyle(
                        color: yazi,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (secili)
              Positioned(
                top: -6,
                right: -6,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: KoltukRenkleri.cinsiyet(seciliCinsiyet!),
                  child: Text(
                    seciliCinsiyet == Cinsiyet.kadin ? 'K' : 'E',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
