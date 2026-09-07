import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/gudang_provider.dart';
import '../models/gudang_model.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/light_theme.dart';


class PackingScreen extends StatefulWidget {
  final String idGudang;
  const PackingScreen({super.key, required this.idGudang});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GudangProvider>().fetchTugas();
    });
  }

  void _konfirmasiPacking(String idDokumen, String namaBarang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: LightTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: LightTheme.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LightTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_box_outlined, color: LightTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text("Konfirmasi Packing", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: LightTheme.textPrimary)),
            ),
          ],
        ),
        content: Text(
          "Barang '$namaBarang' sudah selesai dipacking dan siap diserahkan ke Supir?",
          style: const TextStyle(fontSize: 14, color: LightTheme.textSecondary, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Belum", style: TextStyle(color: LightTheme.textTertiary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<GudangProvider>();
              final result = await provider.selesaikanPacking(idDokumen, widget.idGudang);
              if (mounted) {
                if (result['status'] == 'success') {
                  CustomSnackbar.show(context, "✅ Barang siap dikirim!");
                } else {
                  CustomSnackbar.show(context, result['message'] ?? 'Gagal', isError: true);
                }
              }
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text("Sudah Siap", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Daftar Tugas Packing', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer<GudangProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchTugas(),
              color: LightTheme.primary,
              backgroundColor: LightTheme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  
                  if (provider.isLoading && provider.tugasList.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: LightTheme.primary)),
                    )
                  else if (provider.errorMessage != null && provider.tugasList.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: const Color(0xFFEF4444)),
                            const SizedBox(height: 16),
                            Text(provider.errorMessage!, style: const TextStyle(color: const Color(0xFFEF4444))),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: () => provider.fetchTugas(), child: const Text('Coba Lagi')),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      sliver: provider.tugasList.isEmpty
                          ? SliverToBoxAdapter(
                              child: const EmptyStateWidget(
                                icon: Icons.inventory_2_outlined,
                                title: 'Semua tugas selesai! 🎉',
                                subtitle: 'Tarik ke bawah untuk mengecek tugas baru',
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildPackingCard(provider.tugasList[index])
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80))
                                    .slideY(begin: 0.05, end: 0, duration: 400.ms),
                                childCount: provider.tugasList.length,
                              ),
                            ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  
  
  Widget _buildPackingCard(GudangModel item) {
    bool isDone = item.statusPengiriman == 'Siap Dikirim' ||
        item.statusPengiriman == 'Dalam Perjalanan' ||
        item.statusPengiriman == 'Sampai Tujuan';
    String statusText = isDone ? 'Siap Dikirim' : 'Menunggu';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: isDone
          ? BoxDecoration(
              color: LightTheme.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LightTheme.success.withValues(alpha: 0.15)),
            )
          : BoxDecoration(color: LightTheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: LightTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.nomorDokumen,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDone ? LightTheme.textTertiary : LightTheme.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              StatusBadge(status: statusText),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: LightTheme.border),
          ),
          _buildInfoRow(Icons.inventory_2_outlined, "Barang:", "[${item.kodeBarang}] ${item.namaBarang}", isDone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.tag_rounded, "Jumlah:", "${item.jumlahPacking} Unit", isDone, isBold: true),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "Tujuan:", item.tujuanPengiriman, isDone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline_rounded, "Supir:", item.namaSupir ?? '-', isDone),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isDone ? null : () => _konfirmasiPacking(item.idDokumen.toString(), item.namaBarang),
              icon: Icon(isDone ? Icons.check_circle_rounded : Icons.check_box_outlined, size: 18),
              label: Text(
                isDone ? "SUDAH DIPACKING" : "Selesai Packing",
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? LightTheme.success : LightTheme.primary,
                foregroundColor: isDone ? Colors.white : Colors.white,
                disabledBackgroundColor: LightTheme.success.withValues(alpha: 0.7),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDone, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: LightTheme.textTertiary),
        ),
        const SizedBox(width: 8),
        Text("$label ", style: TextStyle(fontSize: 13, color: LightTheme.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDone ? LightTheme.textTertiary : LightTheme.textPrimary,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
