<?php
$file = 'lib/shared/screens/dashboard_screen.dart';
$content = file_get_contents($file);

// 1. Add imports
$imports = "import '../../features/auth/screens/profil_screen.dart';\nimport '../../features/admin/screens/notification_screen.dart';\n";
$content = str_replace("import '../../features/supir/screens/tugas_supir_screen.dart';", "import '../../features/supir/screens/tugas_supir_screen.dart';\n" . $imports, $content);

// 2. Remove _logout function
$content = preg_replace('/Future<void> _logout\(BuildContext context\) async \{.*?  \}\n\n/s', '', $content);

// 3. Update _buildTabs
$tabs_replace = <<<EOD
  List<Widget> _buildTabs(String role) {
    switch (role) {
      case 'gudang':
        return [
          _buildHomeTab(),
          PackingScreen(idGudang: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role),
        ];
      case 'supir':
        return [
          _buildHomeTab(),
          TugasSupirScreen(idSupir: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role),
        ];
      case 'spv':
        return [
          _buildHomeTab(),
          PemeriksaanScreen(idSpv: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role),
        ];
      default:
        return [_buildHomeTab()];
    }
  }
EOD;
$content = preg_replace('/List<Widget> _buildTabs\(String role\) \{.*?\n  \}/s', $tabs_replace, $content);

// 4. Update _buildNavData
$nav_replace = <<<EOD
  List<Map<String, dynamic>> _buildNavData(String role) {
    switch (role) {
      case 'gudang':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.inventory_2_rounded, 'label': 'Packing'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      case 'supir':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.local_shipping_rounded, 'label': 'Tugas'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      case 'spv':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.fact_check_rounded, 'label': 'Periksa'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      default:
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
    }
  }
EOD;
$content = preg_replace('/List<Map<String, dynamic>> _buildNavData\(String role\) \{.*?\n  \}/s', $nav_replace, $content);

// 5. Replace logout icon with notification icon in _buildTopHeader
$header_replace = <<<EOD
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LightTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: LightTheme.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: LightTheme.textPrimary, size: 22),
            ),
          ),
EOD;
$content = preg_replace('/GestureDetector\(\s*onTap: \(\) => _logout\(context\),.*?child: const Icon\(Icons\.logout_rounded, color: LightTheme\.textPrimary, size: 22\),\s*\),\s*\),/s', $header_replace . "\n        ", $content);

// 6. Add Riwayat Terakhir section to _buildHomeTab
$home_tab_replace = <<<EOD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _statsLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: LightTheme.primary),
                    ))
                  : _BentoGrid(stats: _stats, role: _getNormalizedRole()),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _statsLoading ? const SizedBox.shrink() : _buildRiwayatTerakhir(),
            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.05, end: 0),
          ),
EOD;
$content = preg_replace('/SliverToBoxAdapter\(\s*child: Padding\(\s*padding: const EdgeInsets\.fromLTRB\(24, 24, 24, 0\),\s*child: _statsLoading.*?_BentoGrid\(stats: _stats, role: _getNormalizedRole\(\)\),\s*\)\.animate\(\)\.fadeIn\(duration: 600\.ms\)\.slideY\(begin: 0\.05, end: 0\),\s*\),/s', $home_tab_replace, $content);

// 7. Add _buildRiwayatTerakhir function at the end of class before _getRoleLabel
$riwayat_func = <<<EOD
  Widget _buildRiwayatTerakhir() {
    final riwayatList = _stats['riwayat_terbaru'] as List? ?? [];
    if (riwayatList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LightTheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...riwayatList.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LightTheme.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history_rounded, color: LightTheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(item['subtitle'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: LightTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(item['status'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LightTheme.primary)),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

EOD;
$content = str_replace('String _getRoleLabel() {', $riwayat_func . '  String _getRoleLabel() {', $content);

file_put_contents($file, $content);
echo "Refactored dashboard_screen.dart\n";
?>
