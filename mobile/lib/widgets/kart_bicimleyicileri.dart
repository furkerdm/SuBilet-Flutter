import 'package:flutter/services.dart';

import '../models/kart_dogrulama.dart';

/// Kart numarasını yazarken 4'erli gruplar: 4242 4242 4242 4242.
/// Rakam dışındaki karakterler atılır, 16 haneden fazlası alınmaz.
class KartNumarasiBicimleyici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var haneler = KartDogrulama.rakamlar(newValue.text);
    if (haneler.length > KartDogrulama.kartNumarasiUzunlugu) {
      haneler = haneler.substring(0, KartDogrulama.kartNumarasiUzunlugu);
    }

    final metin = StringBuffer();
    for (var i = 0; i < haneler.length; i++) {
      if (i > 0 && i % 4 == 0) metin.write(' ');
      metin.write(haneler[i]);
    }

    // İmleç, önündeki rakam sayısı korunarak yeni metne taşınır; böylece
    // ortadan bir hane silinince imleç sona kaçmaz
    final imlec = newValue.selection.end.clamp(0, newValue.text.length);
    var oncekiRakam = KartDogrulama.rakamlar(newValue.text.substring(0, imlec))
        .length;
    if (oncekiRakam > haneler.length) oncekiRakam = haneler.length;
    final konum = oncekiRakam == 0 ? 0 : oncekiRakam + (oncekiRakam - 1) ~/ 4;

    return TextEditingValue(
      text: metin.toString(),
      selection: TextSelection.collapsed(offset: konum),
    );
  }
}

/// Son kullanma tarihini AA/YY biçiminde yazdırır; iki haneden sonra "/"
/// kendiliğinden gelir.
class SonKullanmaBicimleyici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var haneler = KartDogrulama.rakamlar(newValue.text);
    if (haneler.length > 4) haneler = haneler.substring(0, 4);

    final metin = haneler.length > 2
        ? '${haneler.substring(0, 2)}/${haneler.substring(2)}'
        : haneler;

    return TextEditingValue(
      text: metin,
      selection: TextSelection.collapsed(offset: metin.length),
    );
  }
}
