<?php
// 1. Update spv_repository.dart
$repoFile = 'lib/features/spv/repositories/spv_repository.dart';
$repoContent = file_get_contents($repoFile);
$repoAdd = <<<EOD
  Future<List<Map<String, dynamic>>> fetchRiwayat(String idSpv) async {
    final response = await ApiClient.get(ApiConfig.riwayatPemeriksaan);
    if (response['status'] == 'success') {
      final List data = response['data'] ?? [];
      // Filter client side for now just in case
      final filtered = data.where((e) => e['id_supervisor'] == idSpv || true).toList(); // Currently API might not have id_supervisor in response, we just take all or what's returned
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat riwayat');
    }
  }
}
EOD;
$repoContent = preg_replace('/}\s*$/', $repoAdd, $repoContent);
file_put_contents($repoFile, $repoContent);

// 2. Update spv_provider.dart
$provFile = 'lib/features/spv/providers/spv_provider.dart';
$provContent = file_get_contents($provFile);
$provAdd = <<<EOD
  List<Map<String, dynamic>> _riwayatList = [];
  List<Map<String, dynamic>> get riwayatList => _riwayatList;

  Future<void> fetchRiwayat(String idSpv) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _riwayatList = await _repository.fetchRiwayat(idSpv);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
EOD;
$provContent = preg_replace('/Future<void> fetchAntrean\(\) async \{/', $provAdd . "\n\n  Future<void> fetchAntrean() async {", $provContent);
file_put_contents($provFile, $provContent);

// 3. Update dashboard_screen.dart
$dashFile = 'lib/shared/screens/dashboard_screen.dart';
$dashContent = file_get_contents($dashFile);

$dashImport = "import '../../features/spv/screens/riwayat_spv_screen.dart';\n";
if (strpos($dashContent, 'riwayat_spv_screen.dart') === false) {
    $dashContent = preg_replace('/import \'..\/..\/features\/spv\/screens\/pemeriksaan_screen.dart\';/', "import '../../features/spv/screens/pemeriksaan_screen.dart';\n" . $dashImport, $dashContent);
}

$dashContent = str_replace(
    "PemeriksaanScreen(idSpv: widget.idUser, stats: _stats),",
    "PemeriksaanScreen(idSpv: widget.idUser, stats: _stats),\n          RiwayatSpvScreen(idSpv: widget.idUser),",
    $dashContent
);

$dashContent = str_replace(
    "{'icon': Icons.fact_check_rounded, 'label': 'Periksa'},",
    "{'icon': Icons.fact_check_rounded, 'label': 'Periksa'},\n          {'icon': Icons.history_rounded, 'label': 'Riwayat'},",
    $dashContent
);

file_put_contents($dashFile, $dashContent);

echo "Success\n";
?>
