import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../../shared/theme/light_theme.dart';
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
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Laporan', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: LightTheme.textPrimary),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.laporanData == null) {
            return const Center(child: CircularProgressIndicator(color: LightTheme.primary));
          }

          if (provider.errorMessage != null && provider.laporanData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: LightTheme.warning),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: LightTheme.warning)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchLaporan('Semua'), 
                    style: ElevatedButton.styleFrom(backgroundColor: LightTheme.primary),
                    child: const Text('Coba Lagi', style: TextStyle(color: LightTheme.surface)),
                  ),
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
            color: LightTheme.primary,
            backgroundColor: LightTheme.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Stats bar
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
                        const Text('Statistik Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('Total', summary['total'].toString(), LightTheme.primary, LightTheme.surface)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Selesai', summary['selesai'].toString(), LightTheme.surfaceVariant, LightTheme.textPrimary)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Kendala', summary['gagal'].toString(), LightTheme.surfaceVariant, LightTheme.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Mini Visual Bar
                        Builder(
                          builder: (context) {
                            final total = int.tryParse(summary['total'].toString()) ?? 0;
                            final selesai = int.tryParse(summary['selesai'].toString()) ?? 0;
                            final gagal = int.tryParse(summary['gagal'].toString()) ?? 0;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 12,
                                width: double.infinity,
                                color: LightTheme.surfaceVariant,
                                child: Row(
                                  children: [
                                    if (total > 0 && selesai > 0)
                                      Expanded(
                                        flex: selesai,
                                        child: Container(color: LightTheme.success),
                                      ),
                                    if (total > 0 && gagal > 0)
                                      Expanded(
                                        flex: gagal,
                                        child: Container(color: LightTheme.warning),
                                      ),
                                    if (total == 0)
                                      Expanded(child: Container(color: LightTheme.surfaceVariant)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tingkat Sukses', style: TextStyle(fontSize: 11, color: LightTheme.textSecondary, fontWeight: FontWeight.w600)),
                            Text('Tingkat Kendala', style: TextStyle(fontSize: 11, color: LightTheme.textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.only(top: 24, bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            selectedColor: LightTheme.primary.withValues(alpha: 0.1),
                            backgroundColor: LightTheme.surfaceVariant,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? LightTheme.primary : LightTheme.textTertiary,
                            ),
                            side: BorderSide(
                              color: isSelected ? LightTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            showCheckmark: false,
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildDocCard(doc as Map<String, dynamic>)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 60))
                              .slideY(begin: 0.03, end: 0, duration: 400.ms),
                        );
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

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildDocCard(Map<String, dynamic> doc) {
    final status = doc['status_pengiriman'] ?? '-';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: LightTheme.cardDecoration(radius: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LightTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.description_rounded, color: LightTheme.textPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${doc['nomor_dokumen'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(doc['nama_supir'] ?? 'Unassigned', style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary)),
                  ],
                ),
              ),
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
          const SizedBox(height: 20),
          
          _buildDocRow(Icons.inventory_2_outlined, '[${doc['kode_barang'] ?? '-'}] ${doc['nama_barang'] ?? '-'} (${doc['jumlah'] ?? 0} Unit)'),
          const SizedBox(height: 8),
          _buildDocRow(Icons.location_on_outlined, doc['tujuan_pengiriman'] ?? '-'),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: LightTheme.border),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMetaChip(Icons.calendar_today_rounded, doc['tanggal_buat'] ?? '-'),
                  const SizedBox(width: 16),
                  _buildMetaChip(Icons.update_rounded, doc['waktu_update'] ?? '-'),
                ],
              ),
              InkWell(
                onTap: () async {
                  await PdfService.printDokumen(Map<String, dynamic>.from(doc));
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LightTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.print_rounded, size: 18, color: LightTheme.primary),
                ),
              ),
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
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: LightTheme.textTertiary)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: LightTheme.textSecondary, fontWeight: FontWeight.w500, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: LightTheme.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: LightTheme.textTertiary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
