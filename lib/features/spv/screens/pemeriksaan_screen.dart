import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spv_provider.dart';
import '../models/antrean_model.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/app_theme.dart';

class PemeriksaanScreen extends StatefulWidget {
  final String idSpv;
  const PemeriksaanScreen({super.key, required this.idSpv});

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpvProvider>().fetchAntrean();
    });
  }

  void _showPeriksaDialog(AntreanModel item) {
    int bagus = item.jumlahDiharapkan;
    int rusak = 0;
    TextEditingController catatanCtrl = TextEditingController();
    String status = "Lengkap";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.fact_check_outlined, color: AppColors.primaryDark, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text("Pemeriksaan Fisik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Item info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.namaBarang, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text("Tercatat di Resi: ${item.jumlahDiharapkan} Unit", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Counter widgets
                      Row(
                        children: [
                          Expanded(child: _buildCounter(
                            label: "Jumlah Bagus",
                            value: bagus,
                            color: AppColors.success,
                            onIncrement: () => setStateDialog(() => bagus++),
                            onDecrement: () { if (bagus > 0) setStateDialog(() => bagus--); },
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCounter(
                            label: "Jumlah Rusak",
                            value: rusak,
                            color: AppColors.error,
                            onIncrement: () => setStateDialog(() => rusak++),
                            onDecrement: () { if (rusak > 0) setStateDialog(() => rusak--); },
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
                        items: ['Lengkap', 'Kurang', 'Rusak']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => status = val!),
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      const Text("Catatan (Opsional)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: catatanCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(hintText: "Tulis kendala jika ada..."),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Batal"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final provider = context.read<SpvProvider>();
                                final result = await provider.simpanPemeriksaan(
                                  item: item,
                                  idSpv: widget.idSpv,
                                  jumlahBagus: bagus,
                                  jumlahRusak: rusak,
                                  status: status,
                                  catatan: catatanCtrl.text,
                                );
                                if (mounted) {
                                  if (result['status'] == 'success') {
                                    CustomSnackbar.show(context, "✅ Hasil pemeriksaan tersimpan!");
                                  } else {
                                    CustomSnackbar.show(context, result['message'] ?? 'Gagal', isError: true);
                                  }
                                }
                              },
                              child: const Text("Simpan Hasil"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required Color color,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _counterButton(Icons.remove_rounded, onDecrement),
              Text(
                '$value',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
              ),
              _counterButton(Icons.add_rounded, onIncrement),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Antrean Pemeriksaan")),
      body: Consumer<SpvProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.antreanList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.antreanList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.fetchAntrean(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAntrean(),
            color: AppColors.primary,
            child: provider.antreanList.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum ada barang datang',
                    subtitle: 'Tarik ke bawah untuk mengecek kedatangan',
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: provider.antreanList.length,
                    itemBuilder: (context, index) => _buildAntreanCard(provider.antreanList[index]),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAntreanCard(AntreanModel item) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.nomorDokumen, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _buildInfoRow(Icons.inventory_2_outlined, "Barang:", item.namaBarang),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.tag_rounded, "Jumlah di Resi:", "${item.jumlahDiharapkan} Unit", isHighlight: true),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.local_shipping_outlined, "Supir:", item.supir ?? '-'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPeriksaDialog(item),
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text("Periksa Fisik", style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: AppColors.textTertiary)),
        const SizedBox(width: 8),
        Text("$label ", style: const TextStyle(fontSize: 13, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? AppColors.info : AppColors.textPrimary,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
