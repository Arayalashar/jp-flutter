<?php
$files = [
    'lib/features/spv/screens/pemeriksaan_screen.dart',
    'lib/features/gudang/screens/packing_screen.dart',
    'lib/features/supir/screens/tugas_supir_screen.dart'
];

foreach ($files as $file) {
    $content = file_get_contents($file);

    // Replace AppColors to LightTheme
    $content = str_replace("import '../../../shared/theme/app_theme.dart';", "import '../../../shared/theme/light_theme.dart';", $content);
    $content = str_replace('AppColors', 'LightTheme', $content);
    $content = str_replace('AppGlass.elevatedCard(radius: AppRadius.lg)', 'BoxDecoration(color: LightTheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: LightTheme.shadowSm, border: Border.all(color: LightTheme.border))', $content);
    $content = str_replace('AppRadius.xl', '24', $content);
    $content = str_replace('AppRadius.lg', '16', $content);
    $content = str_replace('AppRadius.md', '12', $content);
    $content = str_replace('AppRadius.sm', '8', $content);
    
    // Remove _buildTopHeader and _buildBanner
    $content = preg_replace('/Widget _buildTopHeader\(BuildContext context\) \{.*?\n  \}\n/s', '', $content);
    $content = preg_replace('/Widget _buildBanner\(BuildContext context\) \{.*?\n  \}\n/s', '', $content);

    // In build(), add AppBar and remove the slivers for _buildTopHeader and _buildBanner
    // We will find `return Scaffold(` and add `appBar:`
    $title = "Dashboard";
    if (strpos($file, 'pemeriksaan_screen') !== false) $title = "Antrean Pemeriksaan";
    if (strpos($file, 'packing_screen') !== false) $title = "Daftar Tugas Packing";
    if (strpos($file, 'tugas_supir_screen') !== false) $title = "Daftar Pengiriman";

    $appBar = "      appBar: AppBar(
        title: const Text('$title', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
      ),";

    $content = preg_replace('/return Scaffold\(\s*backgroundColor: LightTheme\.background,\s*body: SafeArea\(/s', "return Scaffold(\n      backgroundColor: LightTheme.background,\n" . $appBar . "\n      body: SafeArea(", $content);

    // Remove the slivers for TopHeader and Banner
    $content = preg_replace('/SliverToBoxAdapter\(\s*child: Padding\(\s*padding: const EdgeInsets\.fromLTRB\(24, 24, 24, 0\),\s*child: _buildTopHeader\(context\),\s*\)\.animate\(\)\.fadeIn\(duration: 400\.ms\),\s*\),\s*SliverToBoxAdapter\(\s*child: Padding\(\s*padding: const EdgeInsets\.fromLTRB\(24, 20, 24, 0\),\s*child: _buildBanner\(context\),\s*\)\.animate\(\)\.fadeIn\(duration: 500\.ms\)\.slideY\(begin: 0\.05, end: 0\),\s*\),/s', '', $content);

    // Save
    file_put_contents($file, $content);
    echo "Refactored $file\n";
}
?>
