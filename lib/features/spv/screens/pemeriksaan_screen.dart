import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/spv_provider.dart';
import '../models/antrean_model.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/light_theme.dart';


class PemeriksaanScreen extends StatefulWidget {
  final String idSpv;
  final Map<String, dynamic> stats;
  const PemeriksaanScreen({super.key, required this.idSpv, required this.stats});

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
                            child: Icon(Icons.fact_check_outlined, color: LightTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text("Pemeriksaan Fisik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Item info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: LightTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LightTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.namaBarang, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text("Tercatat di Resi: ${item.jumlahDiharapkan} Unit", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
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
                            color: LightTheme.success,
                            onIncrement: () => setStateDialog(() => bagus++),
                            onDecrement: () { if (bagus > 0) setStateDialog(() => bagus--); },
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCounter(
                            label: "Jumlah Rusak",
                            value: rusak,
                            color: const Color(0xFFEF4444),
                            onIncrement: () => setStateDialog(() => rusak++),
                            onDecrement: () { if (rusak > 0) setStateDialog(() => rusak--); },
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        dropdownColor: LightTheme.surface,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: LightTheme.textTertiary),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LightTheme.textPrimary),
                        items: ['Lengkap', 'Kurang', 'Rusak']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: LightTheme.textPrimary))))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => status = val!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: LightTheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LightTheme.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LightTheme.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: LightTheme.primary)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text("Catatan (Opsional)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: catatanCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14, color: LightTheme.textPrimary),
                        decoration: const InputDecoration(hintText: "Tulis kendala jika ada..."),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LightTheme.textSecondary,
                                side: const BorderSide(color: LightTheme.border),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w700)),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LightTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Simpan Hasil", style: TextStyle(fontWeight: FontWeight.w700)),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: LightTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LightTheme.border),
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
      color: LightTheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: LightTheme.textSecondary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Antrean Pemeriksaan', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        // centerTitle removed to match Lacak Paket
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer<SpvProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchAntrean(),
              color: LightTheme.primary,
              backgroundColor: LightTheme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  
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
                                    decoration: BoxDecoration(color: LightTheme.primary, borderRadius: BorderRadius.circular(20)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('${provider.antreanList.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.surface)),
                                        const Text('Menunggu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.surface)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: LightTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('${widget.stats['hari_ini'] ?? '0'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LightTheme.primary)),
                                        const Text('Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.primary)),
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
                                    if (provider.isLoading && provider.antreanList.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: LightTheme.primary)),
                    )
                  else if (provider.errorMessage != null && provider.antreanList.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: const Color(0xFFEF4444)),
                            const SizedBox(height: 16),
                            Text(provider.errorMessage!, style: const TextStyle(color: const Color(0xFFEF4444))),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: () => provider.fetchAntrean(), child: const Text('Coba Lagi')),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    sliver: provider.antreanList.isEmpty
                        ? SliverToBoxAdapter(
                            child: const EmptyStateWidget(
                              icon: Icons.inventory_2_outlined,
                              title: 'Belum ada barang datang',
                              subtitle: 'Tarik ke bawah untuk mengecek kedatangan',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildAntreanCard(provider.antreanList[index])
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80))
                                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
                              childCount: provider.antreanList.length,
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
                  "[${item.nomorDokumen}] ${item.namaBarang}",
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
          _buildInfoRow(Icons.tag_rounded, "Jumlah di Resi:", "${item.jumlahDiharapkan} Unit", isHighlight: true),
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: LightTheme.textTertiary)),
        const SizedBox(width: 8),
        Text("$label ", style: const TextStyle(fontSize: 13, color: LightTheme.textTertiary, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? const Color(0xFF3B82F6) : LightTheme.textPrimary,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
