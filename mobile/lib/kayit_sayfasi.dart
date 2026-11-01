import 'package:flutter/material.dart';
import 'giris_sayfasi.dart';

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _epostaController = TextEditingController();
  final _telefonController = TextEditingController();
  final _sifreController = TextEditingController();

  bool _sifreGizli = true;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _epostaController.dispose();
    _telefonController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  void _kayitOl() {
    final formGecerli = _formKey.currentState!.validate();
    if (!formGecerli) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kayıt başarılı! Hoş geldin ${_adController.text.trim()}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞuBilet Kayıt Ol'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: 'Ad',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (d) => (d == null || d.trim().isEmpty) ? 'Ad alanı boş bırakılamaz.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _soyadController,
                decoration: const InputDecoration(
                  labelText: 'Soyad',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (d) => (d == null || d.trim().isEmpty) ? 'Soyad alanı boş bırakılamaz.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _epostaController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (d) {
                  if (d == null || d.trim().isEmpty) return 'E-posta adresi girin.';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(d.trim())) return 'Geçerli bir e-posta formatı girin.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Cep Telefonu',
                  hintText: '5XX XXX XX XX',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (d) {
                  if (d == null || d.trim().isEmpty) return 'Telefon numarası girin.';
                  final rakamlar = d.replaceAll(RegExp(r'\D'), '');
                  if (rakamlar.length < 10 || rakamlar.length > 11) {
                    return 'Geçerli bir telefon numarası girin (10 veya 11 hane).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sifreController,
                obscureText: _sifreGizli,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                  ),
                ),
                validator: (d) {
                  if (d == null || d.isEmpty) return 'Şifre boş bırakılamaz.';
                  if (d.length < 8) return 'Şifre en az 8 karakter olmalıdır.';
                  if (!d.contains(RegExp(r'[A-Z]'))) return 'En az bir büyük harf içermelidir.';
                  if (!d.contains(RegExp(r'[a-z]'))) return 'En az bir küçük harf içermelidir.';
                  if (!d.contains(RegExp(r'[0-9]'))) return 'En az bir rakam içermelidir.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _kayitOl,
                icon: const Icon(Icons.person_add),
                label: const Text('Kayıt Ol'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GirisSayfasi()),
                    );
                  }
                },
                child: const Text('Zaten bir hesabınız var mı? Giriş Yapın'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}