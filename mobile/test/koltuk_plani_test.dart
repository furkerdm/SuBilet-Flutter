import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/enumlar.dart';
import 'package:mobile/models/koltuk_plani.dart';

void main() {
  test('2+2 düzende koltuklar ikişer ikişer yan yanadır', () {
    const plan = KoltukPlani(KoltukDuzeni.ikiArtiIki, 10);

    expect(
      [for (var no = 1; no <= 10; no++) plan.yanKoltuk(no)],
      [
        2, 1, 4, 3, 6, 5, 8, 7, 10, 9, //
      ],
    );
    expect(plan.yanKoltuk(0), isNull);
    expect(plan.yanKoltuk(11), isNull);
  });

  test('2+1 düzende tekli koltuğun yanı yoktur', () {
    const plan = KoltukPlani(KoltukDuzeni.ikiArtiBir, 11);

    expect(
      [for (var no = 1; no <= 11; no++) plan.yanKoltuk(no)],
      [
        null, 3, 2, null, 6, 5, null, 9, 8, null, null, //
      ],
    );
  });

  test('Sıralar koridorun iki yanına göre ayrılır, eksik koltuk boş kalır', () {
    final ikiArtiIki = const KoltukPlani(KoltukDuzeni.ikiArtiIki, 10).siralar;
    expect(ikiArtiIki.map((s) => [...s.sol, ...s.sag]).toList(), [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 10, null, null],
    ]);
    expect(ikiArtiIki.first.sol, [1, 2]);

    final ikiArtiBir = const KoltukPlani(KoltukDuzeni.ikiArtiBir, 7).siralar;
    expect(ikiArtiBir.map((s) => [s.sol, s.sag]).toList(), [
      [
        [1],
        [2, 3],
      ],
      [
        [4],
        [5, 6],
      ],
      [
        [7],
        [null, null],
      ],
    ]);
  });
}
