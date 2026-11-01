import 'package:flutter/material.dart';

// Kayıt formunda üyelik sözleşmesinin onaylanmasını isteyen onay kutusu.
// Form doğrulanırken işaretli değilse kutunun altında hata mesajı gösterir.
class SozlesmeOnayi extends FormField<bool> {
  SozlesmeOnayi({super.key, super.onSaved, ValueChanged<bool>? onChanged})
    : super(
        initialValue: false,
        validator: (onaylandi) => onaylandi == true
            ? null
            : 'Kayıt olmak için üyelik sözleşmesini onaylamalısınız.',
        builder: (alan) {
          return CheckboxListTile(
            value: alan.value ?? false,
            onChanged: (deger) {
              alan.didChange(deger);
              // Hata gösteriliyorsa kutu işaretlenince hemen kalkar
              if (alan.hasError) alan.validate();
              onChanged?.call(deger ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            isError: alan.hasError,
            title: const Text(
              'Üyelik sözleşmesini ve KVKK aydınlatma metnini okudum, '
              'kabul ediyorum.',
            ),
            subtitle: alan.hasError
                ? Text(
                    alan.errorText!,
                    style: TextStyle(
                      color: Theme.of(alan.context).colorScheme.error,
                    ),
                  )
                : null,
          );
        },
      );
}
