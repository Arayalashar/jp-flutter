<?php
$files = [
    'lib/features/spv/screens/pemeriksaan_screen.dart',
    'lib/features/gudang/screens/packing_screen.dart',
    'lib/features/supir/screens/tugas_supir_screen.dart',
    'lib/shared/screens/dashboard_screen.dart'
];

foreach ($files as $file) {
    if(!file_exists($file)) continue;
    $content = file_get_contents($file);

    $content = str_replace('LightTheme.error', 'const Color(0xFFEF4444)', $content);
    $content = str_replace('LightTheme.borderLight', 'LightTheme.border', $content);
    $content = str_replace('LightTheme.info', 'const Color(0xFF3B82F6)', $content);
    $content = str_replace('LightTheme.textOnPrimary', 'Colors.white', $content);
    $content = str_replace('LightTheme.shadowSm', '[BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]', $content);
    $content = str_replace('LightTheme.shadowMd', '[BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))]', $content);
    
    // Also remove unused imports
    $content = str_replace("import '../../auth/providers/auth_provider.dart';", "", $content);
    $content = str_replace("import '../../features/admin/screens/laporan_screen.dart';", "", $content);
    $content = str_replace("import '../../features/admin/screens/riwayat_pemeriksaan_screen.dart';", "", $content);

    file_put_contents($file, $content);
    echo "Fixed errors in $file\n";
}
?>
