import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supir_provider.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/app_theme.dart';

class TugasSupirScreen extends StatefulWidget {
  final String idSupir;
  const TugasSupirScreen({super.key, required this.idSupir});

  @override
  State<TugasSupirScreen> createState() => _TugasSupirScreenState();
}

class _TugasSupirScreenState extends State<TugasSupirScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupirProvider>().fetchTugas(widget.idSupir);
    });
  }

  void _showUpdateDialog(Map<String, dynamic> tugas) {
    String selectedStatus = "Dalam Perjalanan";
    TextEditingController ketController = TextEditingController();

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
                            child: const Icon(Icons.local_shipping_outlined, color: AppColors.primaryDark, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text("Update Pengiriman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dokumen info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tugas['nomor_dokumen'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text("Tujuan: ${tugas['tujuan_pengiriman']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text("Status Terbaru", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
                        items: ['Dalam Perjalanan', 'Sampai Tujuan', 'Gagal Kirim']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      const Text("Keterangan Tambahan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ketController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(hintText: "Nama Penerima / Alasan Gagal..."),
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
                                final provider = context.read<SupirProvider>();
                                final result = await provider.updateStatus(
                                  idDokumen: tugas['id_dokumen'].toString(),
                                  status: selectedStatus,
                                  keterangan: ketController.text,
                                  idSupir: widget.idSupir,
                                );
                                if (mounted) {
                                  if (result['status'] == 'success') {
                                    CustomSnackbar.show(context, "✅ Status berhasil diperbarui!");
                                  } else {
                                    CustomSnackbar.show(context, result['message'] ?? 'Gagal', isError: true);
                                  }
                                }
                              },
                              child: const Text("Simpan Status"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Tugas Pengiriman")),
      body: Consumer<SupirProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tugasList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.tugasList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.fetchTugas(widget.idSupir), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTugas(widget.idSupir),
            color: AppColors.primary,
            child: provider.tugasList.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.local_shipping_outlined,
                    title: 'Belum ada tugas pengiriman',
                    subtitle: 'Tarik ke bawah untuk memuat ulang',
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: provider.tugasList.length,
                    itemBuilder: (context, index) => _buildTugasCard(provider.tugasList[index]),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> tugas) {
    final status = tugas['status_pengiriman'] ?? 'Pending';
    bool isSelesai = status == 'Sampai Tujuan';

    // Timeline steps
    final steps = ['Siap Dikirim', 'Dalam Perjalanan', 'Sampai Tujuan'];
    int currentStepIndex = steps.indexOf(status);
    if (currentStepIndex < 0) currentStepIndex = -1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelesai ? AppColors.primarySurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isSelesai ? AppColors.primaryMuted : Colors.transparent),
        boxShadow: isSelesai ? null : AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tugas['nomor_dokumen'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isSelesai ? AppColors.textTertiary : AppColors.textPrimary),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _buildInfoRow(Icons.description_outlined, "Tipe:", tugas['jenis_dokumen'], isSelesai),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "Tujuan:", tugas['tujuan_pengiriman'], isSelesai, isHighlight: !isSelesai),

          // Timeline
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (i) {
              bool done = i <= currentStepIndex;
              bool isCurrent = i == currentStepIndex;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: done ? AppColors.primary : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            border: isCurrent ? Border.all(color: AppColors.primaryLight, width: 2) : null,
                          ),
                          child: done
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i].replaceAll(' ', '\n'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                            color: done ? AppColors.primary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < currentStepIndex ? AppColors.primary : AppColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          if (!isSelesai) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateDialog(tugas),
                icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                label: const Text("Update Status", style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isSelesai, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: AppColors.textTertiary)),
        const SizedBox(width: 8),
        Text("$label ", style: TextStyle(fontSize: 13, color: isSelesai ? AppColors.textTertiary : AppColors.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isSelesai ? AppColors.textTertiary : (isHighlight ? AppColors.info : AppColors.textPrimary),
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
