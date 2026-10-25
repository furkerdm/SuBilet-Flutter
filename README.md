# ŞuBilet – Çevrim İçi Otobüs Bileti Satış Mobil Uygulaması

BLM4587 iOS ile Mobil Uygulama Geliştirme I (Flutter) dersi dönem projesi (2026–2027 Güz).

ŞuBilet Mobil, Türkiye genelindeki otobüs firmalarının seferlerini tek bir çatı altında toplayarak kullanıcıların şehirlerarası sefer arayıp karşılaştırabildiği, interaktif koltuk planı üzerinden seçim yapıp bilet alabildiği bir mobil pazar yeri uygulamasıdır. Proje; Flutter mobil istemcisi ile C# ASP.NET Core Web API arka uç servisinin entegrasyonu üzerine kuruludur.

## Ekip

| Ad Soyad | Öğrenci No | GitHub | Lider olduğu haftalar |
|---|---|---|---|
| Furkan ERDEM | 21290636 | [@furkerdm](https://github.com/furkerdm) | 1, 2, 3, 4, 5 |
| Semih TAKILAN | 23291251 | [@semihtakilan](https://github.com/semihtakilan) | 6, 7, 8, 9 |

## Teknolojiler

- **Mobil İstemci:** Flutter 3.x, Dart 3.x, Material 3
- **Mobil Paketler:** `http`, `shared_preferences`, `intl`, `qr_flutter` (ilerleyen haftalarda eklenecek)
- **Arka Uç (Web API - 6. Haftada Eklenecek):** C# / ASP.NET Core 10 Web API, Swagger / OpenAPI
- **Veritabanı & ORM (Arka Uç):** PostgreSQL, Entity Framework Core (Code-First migration)
- **Kimlik & Yetkilendirme:** JWT (JSON Web Token), Rol Yönetimi (Admin, Yolcu, Ziyaretçi)

## Kurulum ve Çalıştırma

### 1. Gereksinimleri kurun

- **Flutter SDK:** Flutter 3.x (stable). Kontrol: `flutter --version`
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

## Proje Yapısı

Proje şu anda 1. hafta mobil isterlerini içermektedir. Arka uç Web API projesi (`/api`), ders planı doğrultusunda 6. haftada depoya dahil edilecektir.

```text
SuBilet/
└── mobile/                      # Flutter mobil uygulaması (subilet_mobile)
    ├── lib/
    │   ├── main.dart            # Başlangıç noktası, Material 3 teması, Sefer Arama ekranı
    │   ├── models/              # (3. haftadan itibaren) Sefer, Bilet veri modelleri
    │   ├── services/            # (6. haftadan itibaren) ApiServisi, http entegrasyonu
    │   ├── pages/               # Sefer listesi, koltuk seçimi, biletlerim, yönetim sayfaları
    │   └── widgets/             # Tekrar kullanılabilir arayüz bileşenleri
    └── pubspec.yaml             # Paket bağımlılıkları ve varlık ayarları
```

*(Not: `/api` arka uç servis klasörü ve migration dosyaları, müfredat takvimine uygun olarak 6. haftada eklenecektir.)*

## Sık Karşılaşılan Hatalar

| Hata / Belirti | Sebep / Çözüm |
|---|---|
| `'flutter' is not recognized` | Flutter SDK `bin` dizini ortam değişkenlerindeki (`Path`) listesine eklenmemiş. |
| `No connected devices found` | Bir Android emülatörü başlatın ya da Chrome'u hedef cihaz olarak seçin (`flutter run -d chrome`). |
| `RenderFlex overflowed by ... pixels` | Arayüz ekrana sığmıyor; taşan widget'ı `Expanded` ile sarın ya da gövdeye `SingleChildScrollView` ekleyin. |
| Değişiklikler ekrana yansımıyor | Arayüz durumunu güncelleyen mantığı `setState(() { ... })` bloğu içine alın. |
| Android derleme hatası (Gradle) | Proje yolunda Türkçe karakter ya da boşluk olmadığından emin olun; `flutter clean` ve `flutter pub get` çalıştırın. |

## Haftalık İlerleme

| Hafta | Lider | Yapılan / Planlanan İşler | Durum |
|:---:|---|---|:---:|
| 1 | Furkan ERDEM | Mobil proje mimarisi (`/mobile`); Material 3 tema altyapısı; Scaffold, Row, Column ile Sefer Arama ana ekranı; şehir değiştirme, dinamik tarih seçimi (Bugün/Yarın) ve SnackBar etkileşimleri | Tamamlandı |
| 2 | Furkan ERDEM | Formlar ve doğrulama: Kayıt/giriş ekranları, `TextFormField`, `validator` kuralları, `DropdownButton` ve klavye taşma koruması | – |
| 3 | Furkan ERDEM | Veri modelleri (`Sefer`, `Otobus`); `ListView.builder` ile dinamik sefer sonuç listesi, sefer kartları (`Card`, `ListTile`) ve boş durum tasarımı | – |
| 4 | Furkan ERDEM | `Navigator` ile sayfa geçişi ve veri aktarımı; 2+1 / 2+2 otobüs koltuk yerleşimi, cinsiyet kuralı ve `AlertDialog`; 1. Sınıf İçi Gösterim | – |
| 5 | Furkan ERDEM | Uygulama iskeleti: `NavigationBar` (alt menü), `Drawer` (yan menü), `IndexedStack`; yolcu bilgileri formu ve kredi kartı simülasyonu | – |
| 6 | Semih TAKILAN | Web API projesinin depoya eklenmesi (`/api`), `http` paketi ve internet izni; ASP.NET Core `/api/seferler` uç noktası entegrasyonu, `ApiServisi`, `FutureBuilder` ile liste yükleme | – |
| 7 | Semih TAKILAN | `shared_preferences` ile oturum ve token saklama; "Biletlerim" ekranı, PNR sorgulama ve bilet iptal akışı (`Dismissible`) | – |
| 8 | Semih TAKILAN | Yönetici (Admin) paneli ve sefer CRUD ekranları; bilet detayında dinamik QR kod (`qr_flutter`); kalıcı açık/koyu tema tercihi | – |
| 9 | Semih TAKILAN | Uçtan uca sistem entegrasyon testleri, responsive kontroller, `README.md` güncellemesi; 2. Sınıf İçi Gösterim ve final teslimi | – |
