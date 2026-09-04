import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../../shared/theme/light_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class RiwayatPemeriksaanScreen extends StatefulWidget {
  const RiwayatPemeriksaanScreen({super.key});

  @override
  State<RiwayatPemeriksaanScreen> createState() => _RiwayatPemeriksaanScreenState();
}

class _RiwayatPemeriksaanScreenState extends State<RiwayatPemeriksaanScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchRiwayat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Lacak Paket', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: LightTheme.textPrimary),
      ),
      body: Consumer<AdminProvider>(
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
                    onPressed: () => provider.fetchRiwayat(), 
                    style: ElevatedButton.styleFrom(backgroundColor: LightTheme.primary),
                    child: const Text('Coba Lagi', style: TextStyle(color: LightTheme.surface)),
                  ),
                ],
              ),
            );
          }

          final listRiwayat = provider.riwayatList;
          final String currentFilter = _selectedFilter ?? 'Semua';
          final List<String> filters = ['Semua', 'Lengkap', 'Rusak'];
          
          int totalLengkap = 0;
          int totalRusak = 0;
          for (var item in listRiwayat) {
            String status = (item['status_pemeriksaan'] ?? '').toString().toLowerCase();
            if (status.contains('lengkap') || status.contains('bagus')) {
              totalLengkap++;
            } else if (status.contains('rusak')) {
              totalRusak++;
            }
          }

          final filtered = currentFilter == 'Semua' 
            ? listRiwayat 
            : listRiwayat.where((item) {
                String status = (item['status_pemeriksaan'] ?? '').toString().toLowerCase();
                if (currentFilter == 'Lengkap') return status.contains('lengkap') || status.contains('bagus');
                if (currentFilter == 'Rusak') return status.contains('rusak');
                return true;
              }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchRiwayat(),
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
                          const Text('Ringkasan Paket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
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
                                      Text('${listRiwayat.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.surface)),
                                      const Text('Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.surface)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(color: LightTheme.surfaceVariant, borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('$totalLengkap', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                                      const Text('Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(color: LightTheme.surfaceVariant, borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('$totalRusak', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                                      const Text('Rusak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: filters.map((filter) {
                          final isSelected = filter == currentFilter;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedFilter = filter);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? LightTheme.textPrimary : LightTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? LightTheme.surface : LightTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildRiwayatCard(filtered[index])
                            .animate()
                            .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80))
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),
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
    final status = item['status_pemeriksaan'] ?? 'Unknown';
    final int bagus = int.tryParse(item['jumlah_bagus'].toString()) ?? 0;
    final int rusak = int.tryParse(item['jumlah_rusak'].toString()) ?? 0;
    final int datang = int.tryParse(item['jumlah_datang'].toString()) ?? 1;
    final double progress = datang > 0 ? (bagus / datang).clamp(0.0, 1.0) : 0.0;
    final progressColor = progress > 0.8 ? LightTheme.success : LightTheme.warning;

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
                  "[${item['kode_barang']}] ${item['nama_barang']}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LightTheme.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LightTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: LightTheme.textPrimary)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: LightTheme.border),
          ),
          _buildInfoRow(Icons.person_outline_rounded, 'Pemeriksa:', item['nama_spv'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_rounded, 'Tanggal:', item['tanggal_pemeriksaan'] ?? '-'),
          const SizedBox(height: 20),

          // Progress bar 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kondisi Barang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                  Text(
                    '${(progress * 100).toInt()}% Bagus',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: progressColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: LightTheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: LightTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Diharapkan', datang.toString(), LightTheme.textSecondary),
                _buildMetric('Bagus', bagus.toString(), LightTheme.success),
                _buildMetric('Rusak', rusak.toString(), rusak > 0 ? const Color(0xFFEF4444) : LightTheme.textTertiary),
              ],
            ),
          ),

          if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Light yellow
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Catatan: ${item['catatan']}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500, height: 1.4),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: LightTheme.textTertiary),
        const SizedBox(width: 10),
        Text("$label ", style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, color: LightTheme.textPrimary, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: LightTheme.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
