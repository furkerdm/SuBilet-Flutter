import 'enumlar.dart';

/// Otobüsün koltuk düzenine göre koltukların sıralara yerleşimi ve yan koltuk
/// bilgisi. Web projesindeki `Servisler/KoltukPlani.cs` ile aynı numaralandırma:
///
///     2+2:  1  2 | koridor |  3  4        2+1:  1 | koridor |  2  3
///           5  6 |         |  7  8              4 |         |  5  6
///
/// Yan koltuk, koridorun aynı tarafında yan yana duran koltuktur (2+2'de 1–2,
/// 3–4; 2+1'de 2–3). 2+1'deki tekli koltuğun yanı yoktur.
class KoltukPlani {
  final KoltukDuzeni duzen;
  final int koltukSayisi;

  const KoltukPlani(this.duzen, this.koltukSayisi);

  int get siradakiKoltukSayisi => duzen == KoltukDuzeni.ikiArtiIki ? 4 : 3;

  /// Koridorun solundaki koltuk sayısı
  int get koridorunSolundaki => duzen == KoltukDuzeni.ikiArtiIki ? 2 : 1;

  /// Koltuğun yanındaki koltuğun numarası; tekli koltukta ya da yan koltuk
  /// otobüste yoksa null
  int? yanKoltuk(int koltukNo) {
    if (koltukNo < 1 || koltukNo > koltukSayisi) return null;

    final konum = (koltukNo - 1) % siradakiKoltukSayisi; // 0 en solda
    final solda = konum < koridorunSolundaki;

    // Koridorun bir tarafında tek koltuk varsa yanı yoktur
    final taraftakiKoltuk = solda
        ? koridorunSolundaki
        : siradakiKoltukSayisi - koridorunSolundaki;
    if (taraftakiKoltuk < 2) return null;

    // Taraftaki ikilinin ilk koltuğuysa yanı bir sonraki, değilse bir önceki
    final taraftakiYeri = solda ? konum : konum - koridorunSolundaki;
    final yan = taraftakiYeri == 0 ? koltukNo + 1 : koltukNo - 1;

    return yan <= koltukSayisi ? yan : null;
  }

  /// Koltuk haritasının sıraları. Her sırada koridorun solundaki ve sağındaki
  /// koltuk numaraları bulunur; son sıra eksikse olmayan koltuklar null kalır.
  List<({List<int?> sol, List<int?> sag})> get siralar {
    final siralar = <({List<int?> sol, List<int?> sag})>[];
    for (var ilk = 1; ilk <= koltukSayisi; ilk += siradakiKoltukSayisi) {
      final koltuklar = [
        for (var no = ilk; no < ilk + siradakiKoltukSayisi; no++)
          no <= koltukSayisi ? no : null,
      ];
      siralar.add((
        sol: koltuklar.sublist(0, koridorunSolundaki),
        sag: koltuklar.sublist(koridorunSolundaki),
      ));
    }
    return siralar;
  }
}
