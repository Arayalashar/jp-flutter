import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/spv_provider.dart';
import '../../../shared/theme/light_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class RiwayatSpvScreen extends StatefulWidget {
  final String idSpv;
  const RiwayatSpvScreen({super.key, required this.idSpv});

  @override
  State<RiwayatSpvScreen> createState() => _RiwayatSpvScreenState();
}

class _RiwayatSpvScreenState extends State<RiwayatSpvScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpvProvider>().fetchRiwayat(widget.idSpv);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Riwayat Antrean', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        // centerTitle dihilangkan agar seragam
      ),
      body: Consumer<SpvProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.riwayatList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: LightTheme.primary));
          }

          if (provider.errorMessage != null && provider.riwayatList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: LightTheme.warning),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: LightTheme.warning)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchRiwayat(widget.idSpv), 
                    style: ElevatedButton.styleFrom(backgroundColor: LightTheme.primary),
                    child: const Text('Coba Lagi', style: TextStyle(color: LightTheme.surface)),
                  ),
                ],
              ),
            );
          }

          final listRiwayat = provider.riwayatList;
          final String currentFilter = _selectedFilter ?? 'Semua';
          final List<String> filters = ['Semua', 'Lengkap', 'Kurang', 'Rusak'];
          
          int totalLengkap = 0;
          int totalKurang = 0;
          int totalRusak = 0;
          
          for (var item in listRiwayat) {
            String status = (item['status_pemeriksaan'] ?? '').toString().toLowerCase();
            if (status.contains('lengkap') || status.contains('bagus')) {
              totalLengkap++;
            } else if (status.contains('kurang')) {
              totalKurang++;
            } else if (status.contains('rusak')) {
              totalRusak++;
            }
          }

          final filtered = currentFilter == 'Semua' 
            ? listRiwayat 
            : listRiwayat.where((item) {
                String status = (item['status_pemeriksaan'] ?? '').toString().toLowerCase();
                if (currentFilter == 'Lengkap') return status.contains('lengkap') || status.contains('bagus');
                if (currentFilter == 'Kurang') return status.contains('kurang');
                if (currentFilter == 'Rusak') return status.contains('rusak');
                return true;
              }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchRiwayat(widget.idSpv),
            color: LightTheme.primary,
            backgroundColor: LightTheme.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                if (listRiwayat.isNotEmpty)
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
                          const Text('Statistik Pemeriksaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(color: LightTheme.primary, borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('$totalLengkap', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.surface)),
                                      const Text('Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.surface)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('$totalKurang', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.primary)),
                                      const Text('Kurang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.primary)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('$totalRusak', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.primary)),
                                      const Text('Rusak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.primary)),
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
                if (listRiwayat.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 8),
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final f = filters[index];
                          final isSelected = f == currentFilter;
                          return ChoiceChip(
                            label: Text(f),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = f),
                            selectedColor: LightTheme.primary,
                            backgroundColor: LightTheme.primary.withValues(alpha: 0.05),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? LightTheme.surface : LightTheme.primary.withValues(alpha: 0.8),
                            ),
                            side: BorderSide(
                              color: isSelected ? LightTheme.primary : LightTheme.primary.withValues(alpha: 0.2),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),
                  ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.history_rounded,
                      title: 'Belum ada riwayat',
                      subtitle: 'Tarik ke bawah untuk memuat ulang',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // padding bottom for fab
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          return _buildRiwayatCard(item)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 50))
                              .slideY(begin: 0.05, end: 0, duration: 400.ms);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final status = (item['status_pemeriksaan'] ?? '').toString();
    final isRusak = status.toLowerCase() == 'rusak';
    final isKurang = status.toLowerCase() == 'kurang';
    
    Color statusColor = LightTheme.success;
    if (isRusak) statusColor = const Color(0xFFEF4444);
    if (isKurang) statusColor = LightTheme.warning;

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
                  "[${item['kode_barang'] ?? '-'}] ${item['nama_barang'] ?? '-'}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LightTheme.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: LightTheme.border),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.inventory_2_outlined,
                  label: "Tiba",
                  value: "${item['jumlah_datang'] ?? 0}",
                  color: const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: "Bagus",
                  value: "${item['jumlah_bagus'] ?? 0}",
                  color: LightTheme.success,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.cancel_outlined,
                  label: "Rusak",
                  value: "${item['jumlah_rusak'] ?? 0}",
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          if (item['catatan'] != null && item['catatan'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LightTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 16, color: LightTheme.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['catatan'].toString(),
                      style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem({required IconData icon, required String label, required String value, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: LightTheme.textSecondary, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ],
    );
  }
}
