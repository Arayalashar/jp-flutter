import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/supir_provider.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/light_theme.dart';


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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: LightTheme.surface,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    color: LightTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: LightTheme.border),
                  ),
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
                              color: LightTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.local_shipping_outlined, color: LightTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text("Update Pengiriman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dokumen info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: LightTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LightTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tugas['nomor_dokumen'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text("Tujuan: ${tugas['tujuan_pengiriman']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: LightTheme.textTertiary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text("Status Terbaru", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        dropdownColor: LightTheme.surface,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: LightTheme.textTertiary),
                        items: ['Dalam Perjalanan', 'Sampai Tujuan', 'Gagal Kirim']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      const Text("Keterangan Tambahan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ketController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14, color: LightTheme.textPrimary),
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
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Daftar Pengiriman', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer<SupirProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchTugas(widget.idSupir),
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
                            ElevatedButton(onPressed: () => provider.fetchTugas(widget.idSupir), child: const Text('Coba Lagi')),
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
                              icon: Icons.local_shipping_outlined,
                              title: 'Belum ada tugas pengiriman',
                              subtitle: 'Tarik ke bawah untuk memuat ulang',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildTugasCard(provider.tugasList[index])
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
      decoration: isSelesai
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
                  tugas['nomor_dokumen'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isSelesai ? LightTheme.textTertiary : LightTheme.textPrimary),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: LightTheme.border),
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
                            color: done ? LightTheme.primary : LightTheme.surfaceVariant,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(color: LightTheme.primary.withValues(alpha: 0.5), width: 2)
                                : null,
                            boxShadow: isCurrent
                                ? [BoxShadow(color: LightTheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
                                : null,
                          ),
                          child: done
                              ? Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i].replaceAll(' ', '\n'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                            color: done ? LightTheme.primary : LightTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: i < currentStepIndex ? LightTheme.primary : LightTheme.border,
                            borderRadius: BorderRadius.circular(1),
                          ),
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
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: LightTheme.textTertiary)),
        const SizedBox(width: 8),
        Text("$label ", style: TextStyle(fontSize: 13, color: LightTheme.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isSelesai ? LightTheme.textTertiary : (isHighlight ? const Color(0xFF3B82F6) : LightTheme.textPrimary),
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
