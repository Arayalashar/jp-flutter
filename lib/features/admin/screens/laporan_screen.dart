import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/utils/pdf_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Menunggu', 'Siap Dikirim', 'Dalam Perjalanan', 'Sampai Tujuan', 'Gagal Kirim'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchLaporan('Semua');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Laporan Operasional')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.laporanData == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.laporanData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.fetchLaporan('Semua'), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final summary = provider.laporanData?['summary'] ?? {"total": 0, "selesai": 0, "gagal": 0};
          final listDokumen = provider.laporanData?['data'] as List? ?? [];

          // Filter list
          final filtered = _selectedFilter == 'Semua'
              ? listDokumen
              : listDokumen.where((d) => d['status_pengiriman'] == _selectedFilter).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchLaporan('Semua'),
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Stats bar — dark surface
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        StatCardCompact(
                          label: 'Total',
                          value: summary['total'].toString(),
                          bgColor: AppColors.primary,
                          textColor: AppColors.textOnPrimary,
                        ),
                        const SizedBox(width: 10),
                        StatCardCompact(
                          label: 'Selesai',
                          value: summary['selesai'].toString(),
                          bgColor: AppColors.surfaceVariant,
                          textColor: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        StatCardCompact(
                          label: 'Kendala',
                          value: summary['gagal'].toString(),
                          bgColor: AppColors.surfaceVariant,
                          textColor: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final f = _filters[index];
                        final isSelected = f == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = f),
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            backgroundColor: AppColors.surfaceVariant,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // List
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.description_outlined,
                      title: 'Tidak ada dokumen',
                      subtitle: 'Tidak ditemukan dokumen dengan filter "$_selectedFilter"',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = filtered[index];
                        return _buildDocCard(doc)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 60))
                            .slideY(begin: 0.03, end: 0, duration: 400.ms);
                      },
                      childCount: filtered.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocCard(Map<String, dynamic> doc) {
    final status = doc['status_pengiriman'] ?? '-';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: AppGlass.elevatedCard(radius: AppRadius.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doc['nomor_dokumen'] ?? '-',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: status),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  await PdfService.printDokumen(Map<String, dynamic>.from(doc));
                },
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.print_rounded, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDocRow(Icons.description_outlined, doc['jenis_dokumen'] ?? '-'),
          const SizedBox(height: 6),
          _buildDocRow(Icons.person_outline_rounded, doc['nama_supir'] ?? 'Belum ada supir'),
          const SizedBox(height: 6),
          _buildDocRow(Icons.inventory_2_outlined, '[${doc['kode_barang'] ?? '-'}] ${doc['nama_barang'] ?? '-'} (${doc['jumlah'] ?? 0} Unit)'),
          const SizedBox(height: 6),
          _buildDocRow(Icons.location_on_outlined, doc['tujuan_pengiriman'] ?? '-'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          Row(
            children: [
              _buildMetaChip(Icons.calendar_today_rounded, doc['tanggal_buat'] ?? '-'),
              const SizedBox(width: 16),
              _buildMetaChip(Icons.update_rounded, doc['waktu_update'] ?? 'Belum update'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: AppColors.textTertiary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
