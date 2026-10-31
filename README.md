# ŞuBilet – Çevrim İçi Otobüs Bileti Satış Mobil Uygulaması

BLM4587 iOS ile Mobil Uygulama Geliştirme I (Flutter) dersi dönem projesi (2026–2027 Güz).

ŞuBilet Mobil, Türkiye genelindeki otobüs firmalarının seferlerini tek bir çatı altında toplayarak kullanıcıların şehirlerarası sefer arayıp karşılaştırabildiği, interaktif koltuk planı üzerinden seçim yapıp bilet alabildiği bir mobil pazar yeri uygulamasıdır. Proje; Flutter mobil istemcisi ile C# ASP.NET Core Web API arka uç servisinin entegrasyonu üzerine kuruludur.

Arka uç, ŞuBilet web projesiyle **ortaktır** ve [semihtakilan/SuBilet](https://github.com/semihtakilan/SuBilet) deposunda geliştirilir. Web sitesi ve mobil uygulama aynı API'yi ve aynı PostgreSQL veritabanını kullanır; mobilin ihtiyaç duyduğu uç noktalar o depoya eklenir. Bu depoda yalnızca Flutter uygulaması bulunur.

## Ekip

| Ad Soyad | Öğrenci No | GitHub | Lider olduğu haftalar |
|---|---|---|---|
| Furkan ERDEM | 21290636 | [@furkerdm](https://github.com/furkerdm) | 1, 2, 3, 4, 5 |
| Semih TAKILAN | 23291251 | [@semihtakilan](https://github.com/semihtakilan) | 6, 7, 8, 9 |

## Teknolojiler

- **Mobil İstemci:** Flutter 3.x, Dart 3.x, Material 3
- **Mobil Paketler:** `http`, `shared_preferences`, `flutter_secure_storage`, `provider`, `intl`, `qr_flutter` (ilerleyen haftalarda eklenecek)
- **Arka Uç (web projesiyle ortak):** C# / ASP.NET Core 10 Web API, Swagger / OpenAPI – [semihtakilan/SuBilet](https://github.com/semihtakilan/SuBilet)
- **Veritabanı & ORM (Arka Uç):** PostgreSQL, Entity Framework Core (Code-First migration)
- **Kimlik & Yetkilendirme:** JWT (JSON Web Token), Rol Yönetimi (Admin, Yolcu, Ziyaretçi). Firma Yetkilisi rolü yalnızca web sitesinde kullanılır.

## Kurulum ve Çalıştırma

### 1. Gereksinimleri kurun

- **Flutter SDK:** Flutter 3.47.9 veya üstü (stable, Dart 3.13.7+). Kontrol: `flutter --version`; eskiyse `flutter upgrade`
- **Android Geliştirme Ortamı:** Android Studio, Android SDK Build-Tools ve Android Emulator
- **Ortam kontrolü:** `flutter doctor` komutunun sorunsuz olduğunu doğrulayın.

### 2. Projeyi indirin

```bash
git clone https://github.com/furkerdm/SuBilet-Flutter.git
cd SuBilet-Flutter/mobile
```

### 3. Paketleri yükleyin

```bash
flutter pub get
```

### 4. Uygulamayı başlatın

Bir Android emülatör veya fiziksel cihaz bağlıyken:

```bash
flutter run        # ya da tarayıcıda çalıştırmak için: flutter run -d chrome
```

### 5. Ortak arka ucu çalıştırın (6. haftadan itibaren)

Uygulama 6. haftadan itibaren verileri ortak Web API'den alır. Arka ucu kurmak için [web deposunun README'sindeki](https://github.com/semihtakilan/SuBilet#kurulum-sıfırdan) adımları izleyin. API, bilgisayarda `http://localhost:5214` adresinde çalışır.

- **Android emülatör:** Bilgisayardaki API'ye `localhost` ile değil, `http://10.0.2.2:5214` ile ulaşılır.
- **Gerçek cihaz:** Telefon ve bilgisayar aynı ağda olmalı. Arka ucu `dotnet run --urls http://0.0.0.0:5214` ile başlatın ve uygulamada bilgisayarın yerel IP adresini kullanın.

## Proje Yapısı

Bu depoda yalnızca Flutter uygulaması bulunur. Arka uç (Web API ve veritabanı migration'ları) web projesiyle ortaktır ve [semihtakilan/SuBilet](https://github.com/semihtakilan/SuBilet) deposundadır.

```text
SuBilet-Flutter/
└── mobile/                      # Flutter mobil uygulaması (paket adı: mobile)
    ├── lib/
    │   ├── main.dart            # Başlangıç noktası, Material 3 teması, Sefer Arama ekranı
    │   ├── models/              # (3. haftadan itibaren) Sefer, Bilet veri modelleri
    │   ├── services/            # (6. haftadan itibaren) ApiServisi, http entegrasyonu
    │   ├── pages/               # Sefer listesi, koltuk seçimi, biletlerim, yönetim sayfaları
    │   └── widgets/             # Tekrar kullanılabilir arayüz bileşenleri
    └── pubspec.yaml             # Paket bağımlılıkları ve varlık ayarları
```

## Sık Karşılaşılan Hatalar

| Hata / Belirti | Sebep / Çözüm |
|---|---|
| `'flutter' is not recognized` | Flutter SDK `bin` dizini ortam değişkenlerindeki (`Path`) listesine eklenmemiş. |
| `No connected devices found` | Bir Android emülatörü başlatın ya da Chrome'u hedef cihaz olarak seçin (`flutter run -d chrome`). |
| `RenderFlex overflowed by ... pixels` | Arayüz ekrana sığmıyor; taşan widget'ı `Expanded` ile sarın ya da gövdeye `SingleChildScrollView` ekleyin. |
| Değişiklikler ekrana yansımıyor | Arayüz durumunu güncelleyen mantığı `setState(() { ... })` bloğu içine alın. |
| Android derleme hatası (Gradle) | Proje yolunda Türkçe karakter ya da boşluk olmadığından emin olun; `flutter clean` ve `flutter pub get` çalıştırın. |
| `flutter pub get`: "Try using the Flutter SDK version …" | Flutter sürümünüz projenin istediğinden eski; `flutter upgrade` çalıştırın. |
| `flutter analyze` çöküyor (`FormatException: Unexpected end of input`) | Proje yolunda Türkçe karakter var (ör. `ŞuBilet`). Yerine `dart analyze` kullanın ya da projeyi Türkçe karakter içermeyen bir klasöre taşıyın. |
| API'ye bağlanılamıyor (`Connection refused`) | Arka uç çalışmıyor ya da emülatörde `localhost` kullanılmış; adres `http://10.0.2.2:5214` olmalı. |

## Haftalık İlerleme

| Hafta | Lider | Yapılan / Planlanan İşler | Durum |
|:---:|---|---|:---:|
| 1 | Furkan ERDEM | Mobil proje (`/mobile`), Material 3 tema ve Türkçe yerelleştirme; Scaffold, Row, Column ile Sefer Arama ana ekranı; listeden Nereden/Nereye seçimi, Bugün/Yarın ve Türkçe takvimden tarih seçimi (`ElevatedButton`, `FilledButton`, `OutlinedButton`), SnackBar geri bildirimleri; `setState` ile etkileşim, aynı şehirde pasifleşen arama butonu; widget testleri | Tamamlandı |
| 2 | Furkan ERDEM | Kayıt (ad, soyad, e-posta, cep telefonu, şifre) ve giriş formları; `TextFormField` ve web ile aynı `validator` kuralları; şehir seçimi için `DropdownButton` (81 il), sözleşme onayı için `CheckboxListTile`; klavye taşma koruması | – |
| 3 | Furkan ERDEM | Veri modelleri (`Sefer`, `Otobus`, `Sehir`, `Bilet`); `ListView.builder` ile sefer sonuç listesi, sefer kartları (`Card`, `ListTile`) ve boş durum tasarımı; fiyat/saat sıralaması ve firma filtresi | – |
| 4 | Furkan ERDEM | `Navigator` ile sayfa geçişi ve veri aktarımı; 2+1 / 2+2 koltuk yerleşimi, birden fazla koltuk seçimi, yolcu cinsiyeti ve yan koltuk kuralı (`AlertDialog`); 1. Sınıf İçi Gösterim (18 Kasım) | – |
| 5 | Furkan ERDEM | Uygulama iskeleti: `NavigationBar` (alt menü), `Drawer` (yan menü), `IndexedStack`; yolcu bilgileri formu (T.C. kimlik no, cinsiyet), kredi kartı simülasyonu (Luhn); ortak arka uca JWT ile kayıt/giriş uç noktaları | – |
| 6 | Semih TAKILAN | `http` paketi, internet ve geliştirme için HTTP izni; `ApiServisi`, `fromJson`/`toJson`, `FutureBuilder` ile sefer listesi; ortak arka uca koltuk durumu, bilet satın alma, Biletlerim, PNR sorgulama ve iptal uç noktaları | – |
| 7 | Semih TAKILAN | Giriş/kayıt ekranlarının API'ye bağlanması; token için `flutter_secure_storage`, kullanıcı bilgisi için `shared_preferences`, oturum için `provider`; koltuk seçimi ve ödemenin API'ye bağlanması; "Biletlerim", PNR sorgulama ve bilet iptali (`Dismissible`) | – |
| 8 | Semih TAKILAN | Yönetici (Admin) paneli (özet sayaçları) ve sefer ekleme/düzenleme/silme; bilet detayında PNR içeren QR kod (`qr_flutter`); profil sayfası ve kalıcı açık/koyu tema tercihi | – |
| 9 | Semih TAKILAN | Uçtan uca testler, farklı ekran boyutlarında taşma kontrolleri, `README.md` tamamlanması; 2. Sınıf İçi Gösterim (23 Aralık) ve final teslimi | – |
