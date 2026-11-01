import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/giris_sayfasi.dart';

void main() {
  testWidgets('Klavye açıkken giriş formu taşmaz ve kaydırılabilir', (
    tester,
  ) async {
    // Küçük bir telefon ekranı ve açık klavye
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: GirisSayfasi()));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Klavyenin altında kalan kayıt bağlantısına kaydırılarak ulaşılır
    final kayitBaglantisi = find.text('Hesabınız yok mu? Kayıt Olun');
    expect(kayitBaglantisi.hitTestable(), findsNothing);
    await tester.ensureVisible(kayitBaglantisi);
    await tester.pumpAndSettle();
    expect(kayitBaglantisi.hitTestable(), findsOneWidget);
  });
}
