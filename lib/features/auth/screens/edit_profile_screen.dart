import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/light_theme.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _namaController.text = auth.currentUser?.namaLengkap ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await context.read<AuthProvider>().updateProfile(
          _namaController.text,
          _passwordController.text,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? (result['success'] ? 'Berhasil' : 'Gagal')),
          backgroundColor: result['success'] ? LightTheme.success : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: LightTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informasi Dasar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text('Perbarui nama lengkap dan password Anda.', style: TextStyle(fontSize: 14, color: LightTheme.textSecondary)),
              const SizedBox(height: 32),
              
              // Input Nama
              const Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_rounded, color: LightTheme.textTertiary),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // Input Password
              const Text('Password Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Biarkan kosong jika tidak ingin mengubah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_rounded, color: LightTheme.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: LightTheme.textTertiary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Simpan Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 4,
                    shadowColor: LightTheme.primary.withValues(alpha: 0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
