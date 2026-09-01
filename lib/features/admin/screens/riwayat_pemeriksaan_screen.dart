import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class RiwayatPemeriksaanScreen extends StatefulWidget {
  const RiwayatPemeriksaanScreen({super.key});

  @override
  State<RiwayatPemeriksaanScreen> createState() => _RiwayatPemeriksaanScreenState();
}

class _RiwayatPemeriksaanScreenState extends State<RiwayatPemeriksaanScreen> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Pemeriksaan SPV')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.riwayatList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.riwayatList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.fetchRiwayat(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchRiwayat(),
            color: AppColors.primary,
            child: provider.riwayatList.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: 'Belum ada riwayat pemeriksaan',
                    subtitle: 'Tarik ke bawah untuk memuat ulang',
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: provider.riwayatList.length,
                    itemBuilder: (context, index) => _buildRiwayatCard(provider.riwayatList[index]),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(status: status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _buildInfoRow(Icons.person_outline_rounded, 'Pemeriksa:', item['nama_spv'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_rounded, 'Tanggal:', item['tanggal_pemeriksaan'] ?? '-'),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kondisi Barang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                  Text('${(progress * 100).toInt()}% Bagus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: progress > 0.8 ? AppColors.success : AppColors.warning)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? AppColors.success : AppColors.warning),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metrics row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Diharapkan', datang.toString(), AppColors.textSecondary),
                _buildMetric('Bagus', bagus.toString(), AppColors.success),
                _buildMetric('Rusak', rusak.toString(), rusak > 0 ? AppColors.error : AppColors.textTertiary),
              ],
            ),
          ),

          if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Catatan: ${item['catatan']}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500, height: 1.4),
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
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text("$label ", style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, color: valueColor, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
