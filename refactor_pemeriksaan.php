<?php
$file = 'lib/features/spv/screens/pemeriksaan_screen.dart';
$content = file_get_contents($file);

// 1. Update AppBar
$content = str_replace(
    "centerTitle: true,",
    "// centerTitle removed to match Lacak Paket",
    $content
);

// 2. Add Ringkasan Antrean
$ringkasan = <<<EOD
                  if (provider.antreanList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        decoration: const BoxDecoration(
                          color: LightTheme.surface,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          border: Border(bottom: BorderSide(color: LightTheme.border)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ringkasan Antrean', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(color: LightTheme.warning, borderRadius: BorderRadius.circular(20)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('\${provider.antreanList.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.surface)),
                                        const Text('Menunggu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.surface)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
EOD;
$content = preg_replace('/if \(provider\.isLoading && provider\.antreanList\.isEmpty\)/', $ringkasan . '                  if (provider.isLoading && provider.antreanList.isEmpty)', $content);

// 3. Rewrite _buildAntreanCard
$card_replace = <<<EOD
  Widget _buildAntreanCard(AntreanModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: LightTheme.cardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "[\${item.nomorDokumen}] \${item.namaBarang}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LightTheme.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LightTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('Menunggu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LightTheme.warning)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: LightTheme.border),
          ),
          _buildInfoRow(Icons.tag_rounded, "Jumlah di Resi:", "\${item.jumlahDiharapkan} Unit", isHighlight: true),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.local_shipping_outlined, "Supir:", item.supir ?? '-'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showPeriksaDialog(item),
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: const Text("Periksa Fisik", style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightTheme.primary,
                  foregroundColor: LightTheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
EOD;

$content = preg_replace('/Widget _buildAntreanCard\(AntreanModel item\) \{.*?\n  \}\n\n  Widget _buildInfoRow/s', $card_replace . "\n\n  Widget _buildInfoRow", $content);

file_put_contents($file, $content);
echo "Refactored pemeriksaan_screen.dart\n";
?>
