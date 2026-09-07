import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/light_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfilScreen extends StatelessWidget {
  final String nama;
  final String role;
  final Map<String, dynamic> stats;
  
  const ProfilScreen({super.key, required this.nama, required this.role, required this.stats});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LightTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?", style: TextStyle(color: LightTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: LightTheme.textTertiary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboarding_seen', true);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayRole = role.toUpperCase();
    if (role.toLowerCase() == 'gudang' || role.toLowerCase() == 'karyawan_gudang') displayRole = 'STAF GUDANG';
    if (role.toLowerCase() == 'spv' || role.toLowerCase() == 'supervisor') displayRole = 'SUPERVISOR QC';
    if (role.toLowerCase() == 'supir') displayRole = 'SUPIR PENGIRIMAN';

    final initials = nama.isNotEmpty ? nama.trim().split(' ').take(2).map((e) => e.isEmpty ? '' : e[0].toUpperCase()).join() : 'U';

    // Mendapatkan statistik tugas selesai berdasarkan role
    String tugasSelesai = "0";
    if (role.toLowerCase() == 'karyawan_gudang' || role.toLowerCase() == 'gudang') {
      tugasSelesai = stats['total_packing']?.toString() ?? "0";
    } else if (role.toLowerCase() == 'supervisor' || role.toLowerCase() == 'spv') {
      tugasSelesai = stats['total_periksa']?.toString() ?? "0";
    } else if (role.toLowerCase() == 'supir') {
      tugasSelesai = stats['selesai']?.toString() ?? "0";
    }

    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar — orange gradient
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: LightTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ).animate().scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              nama.isNotEmpty ? nama : 'Pengguna',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: LightTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: LightTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                displayRole,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LightTheme.primary, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: LightTheme.cardDecoration(radius: 24),
              child: Column(
                children: [
                  _ProfilRow(icon: Icons.person_rounded, label: 'Nama Lengkap', value: nama),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: LightTheme.border, height: 1),
                  ),
                  _ProfilRow(icon: Icons.shield_rounded, label: 'Peran', value: displayRole),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 24),

            // Edit Profil button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                icon: const Icon(Icons.edit_rounded, color: LightTheme.primary, size: 20),
                label: const Text('Edit Profil', style: TextStyle(color: LightTheme.primary, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: LightTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), // Pill button
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 16),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), // Pill button
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfilRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfilRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: LightTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: LightTheme.textSecondary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: LightTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
