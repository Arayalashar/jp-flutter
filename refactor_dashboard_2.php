<?php
$file = 'lib/shared/screens/dashboard_screen.dart';
$content = file_get_contents($file);

// 1. Update ProfilScreen constructors to include stats: _stats
$content = str_replace(
    "ProfilScreen(nama: widget.nama, role: widget.role),",
    "ProfilScreen(nama: widget.nama, role: widget.role, stats: _stats),",
    $content
);

// 2. Remove the two BentoCards in _BentoGrid
$bento_replace = <<<EOD
class _BentoGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String role;
  
  const _BentoGrid({required this.stats, required this.role});

  @override
  Widget build(BuildContext context) {
    final nTotal = stats['total']?.toString() ?? '0';

    return Column(
      children: [
        // Top full width card
        _buildBentoCard(
          title: "Ringkasan Mingguan",
          subtitle: "Total: \$nTotal",
          isPrimary: true,
          child: _buildMockBarChart(),
        ),
      ],
    );
  }
EOD;

$content = preg_replace('/class _BentoGrid extends StatelessWidget \{.*?\n  Widget build\(BuildContext context\) \{.*?return Column\(\s*children: \[\s*\/\/ Top full width card.*?_buildMockBarChart\(\),\s*\),\s*const SizedBox\(height: 16\),\s*\/\/ Bottom two cards.*?Row\(.*?\]\),\s*\]\);\s*\}/s', $bento_replace, $content);

file_put_contents($file, $content);
echo "Updated dashboard_screen.dart\n";
?>
