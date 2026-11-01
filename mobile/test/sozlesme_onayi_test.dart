import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/widgets/sozlesme_onayi.dart';

const hataMesaji = 'Kayıt olmak için üyelik sözleşmesini onaylamalısınız.';

// Onay kutusunu bir form içinde açar
Future<GlobalKey<FormState>> formuAc(
  WidgetTester tester, {
  ValueChanged<bool>? onChanged,
}) async {
  final formKey = GlobalKey<FormState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: SozlesmeOnayi(onChanged: onChanged),
        ),
      ),
    ),
  );
  return formKey;
}

bool kutuIsaretli(WidgetTester tester) =>
    tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value!;

void main() {
  testWidgets('Sözleşme onaylanmadan form doğrulanmaz', (tester) async {
    final formKey = await formuAc(tester);

    expect(kutuIsaretli(tester), isFalse);
    expect(find.text(hataMesaji), findsNothing);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(hataMesaji), findsOneWidget);
  });

  testWidgets('Kutu işaretlenince form doğrulanır', (tester) async {
    bool? bildirilen;
    final formKey = await formuAc(tester, onChanged: (d) => bildirilen = d);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(kutuIsaretli(tester), isTrue);
    expect(bildirilen, isTrue);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('Hata varken kutu işaretlenince hata kalkar', (tester) async {
    final formKey = await formuAc(tester);
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text(hataMesaji), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(find.text(hataMesaji), findsNothing);
  });

  testWidgets('İşaret kaldırılınca onay geri alınır', (tester) async {
    final formKey = await formuAc(tester);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(kutuIsaretli(tester), isFalse);
    expect(formKey.currentState!.validate(), isFalse);
  });
}
