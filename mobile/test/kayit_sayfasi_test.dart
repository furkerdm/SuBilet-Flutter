import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/kayit_sayfasi.dart';

const sozlesmeHatasi = 'Kayıt olmak için üyelik sözleşmesini onaylamalısınız.';

// Kayıt formunun metin alanlarını geçerli bilgilerle doldurur
Future<void> alanlariDoldur(WidgetTester tester) async {
  const bilgiler = {
    'Ad': 'Semih',
    'Soyad': 'Takılan',
    'E-posta': 'semih@ornek.com',
    'Cep Telefonu': '5321234567',
    'Şifre': 'Sifre123',
  };
  for (final alan in bilgiler.entries) {
    await tester.enterText(
      find.widgetWithText(TextFormField, alan.key),
      alan.value,
    );
  }
}

Future<void> kayitOlaBas(WidgetTester tester) async {
  final buton = find.text('Kayıt Ol');
  await tester.ensureVisible(buton);
  await tester.tap(buton);
  await tester.pump();
}

void main() {
  testWidgets('Klavye açıkken kayıt formu taşmaz ve kaydırılabilir', (
    tester,
  ) async {
    // Küçük bir telefon ekranı ve açık klavye
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: KayitSayfasi()));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Klavyenin altında kalan giriş bağlantısına kaydırılarak ulaşılır
    final girisBaglantisi = find.text(
      'Zaten bir hesabınız var mı? Giriş Yapın',
    );
    expect(girisBaglantisi.hitTestable(), findsNothing);
    await tester.ensureVisible(girisBaglantisi);
    await tester.pumpAndSettle();
    expect(girisBaglantisi.hitTestable(), findsOneWidget);
  });

  testWidgets('Sözleşme onaylanmadan kayıt olunamaz', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KayitSayfasi()));
    await alanlariDoldur(tester);

    await kayitOlaBas(tester);

    expect(find.text(sozlesmeHatasi), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Sözleşme onaylanınca kayıt tamamlanır', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KayitSayfasi()));
    await alanlariDoldur(tester);

    final onay = find.byType(CheckboxListTile);
    await tester.ensureVisible(onay);
    await tester.tap(onay);
    await kayitOlaBas(tester);

    expect(find.text(sozlesmeHatasi), findsNothing);
    expect(find.text('Kayıt başarılı! Hoş geldin Semih'), findsOneWidget);
  });
}
