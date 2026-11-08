import 'package:flutter/material.dart';

import '../models/sefer.dart';

/// Sefer listesinde tek bir seferi gösteren kart.
class SeferKarti extends StatelessWidget {
  final Sefer sefer;

  const SeferKarti({super.key, required this.sefer});

  // 09:30 biçiminde saat metni
  static String _saat(DateTime zaman) {
    final saat = zaman.hour.toString().padLeft(2, '0');
    final dakika = zaman.minute.toString().padLeft(2, '0');
    return '$saat:$dakika';
  }

  // 5 sa 30 dk biçiminde yolculuk süresi
  static String _sure(Duration sure) {
    final saat = sure.inHours;
    final dakika = sure.inMinutes % 60;
    if (dakika == 0) return '$saat sa';
    if (saat == 0) return '$dakika dk';
    return '$saat sa $dakika dk';
  }

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    final sure = sefer.tahminiVarisZamani.difference(sefer.kalkisZamani);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: renkler.primaryContainer,
          foregroundColor: renkler.onPrimaryContainer,
          child: const Icon(Icons.directions_bus),
        ),
        title: Text(
          sefer.firmaAdi,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_saat(sefer.kalkisZamani)} → ${_saat(sefer.tahminiVarisZamani)}'
          ' · ${_sure(sure)}\n'
          '${sefer.koltukDuzeni.gorunenAd} koltuk düzeni',
        ),
        isThreeLine: true,
        trailing: Text(
          '${sefer.fiyat.toStringAsFixed(0)} TL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: renkler.primary,
          ),
        ),
      ),
    );
  }
}
