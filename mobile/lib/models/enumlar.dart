enum KoltukDuzeni {
  ikiArtiBir(1, '2+1'),
  ikiArtiIki(2, '2+2');

  final int deger;
  final String gorunenAd;
  const KoltukDuzeni(this.deger, this.gorunenAd);
}

enum SeferDurumu {
  aktif(0, 'Aktif'),
  iptal(1, 'İptal'),
  tamamlandi(2, 'Tamamlandı');

  final int deger;
  final String gorunenAd;
  const SeferDurumu(this.deger, this.gorunenAd);
}

enum BiletDurumu {
  aktif(0, 'Aktif'),
  iptal(1, 'İptal');

  final int deger;
  final String gorunenAd;
  const BiletDurumu(this.deger, this.gorunenAd);
}

enum Cinsiyet {
  erkek(1, 'Erkek'),
  kadin(2, 'Kadın');

  final int deger;
  final String gorunenAd;
  const Cinsiyet(this.deger, this.gorunenAd);
}