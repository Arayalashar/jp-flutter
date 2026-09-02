import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/theme/app_theme.dart';

class BuatDokumenScreen extends StatefulWidget {
  final String idAdmin;
  const BuatDokumenScreen({super.key, required this.idAdmin});

  @override
  State<BuatDokumenScreen> createState() => _BuatDokumenScreenState();
}

class _BuatDokumenScreenState extends State<BuatDokumenScreen> {
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  String _jenisDokumen = 'Surat Jalan';
  String? _selectedSupir;
  String? _selectedBarang;
  int _currentStep = 0;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    // Auto-generate nomor resi
    final now = DateTime.now();
    _nomorController.text = 'NVG-${now.year}${now.month.toString().padLeft(2, '0')}-${now.millisecond.toString().padLeft(3, '0')}';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchMasterData();
    });
  }

  @override
  void dispose() {
    _nomorController.dispose();
    _tujuanController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _nomorController.text.trim().isNotEmpty && _tujuanController.text.trim().isNotEmpty;
      case 1:
        return _selectedSupir != null && _selectedBarang != null && _jumlahController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _simpanDokumen() async {
    final provider = context.read<AdminProvider>();
    final result = await provider.buatDokumen(
      jenisDokumen: _jenisDokumen,
      nomorDokumen: _nomorController.text.trim(),
      tujuan: _tujuanController.text.trim(),
      idSupir: _selectedSupir!,
      idBarang: _selectedBarang!,
      jumlah: _jumlahController.text.trim(),
      idAdmin: widget.idAdmin,
    );

    if (mounted) {
      if (result['status'] == 'success') {
        setState(() => _showSuccess = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        CustomSnackbar.show(context, result['message'] ?? 'Gagal membuat dokumen', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessOverlay();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Dokumen Baru'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.masterData == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.masterData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.fetchMasterData(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Step indicator
              _buildStepIndicator(),
              
              // Step content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(provider),
                  ),
                ),
              ),

              // Bottom navigation buttons
              _buildBottomButtons(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Informasi', 'Penugasan', 'Konfirmasi'];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          bool isActive = i == _currentStep;
          bool isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.primary
                        : (isActive ? AppColors.primary : AppColors.surfaceVariant),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, size: 16, color: AppColors.textOnPrimary)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isActive ? AppColors.textOnPrimary : AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 16,
                    height: 1.5,
                    color: isDone ? AppColors.primary : AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(AdminProvider provider) {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2(provider);
      case 2:
        return _buildStep3(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Informasi Dokumen',
          icon: Icons.description_outlined,
          children: [
            _buildLabel('Tipe Dokumen'),
            _buildDropdown<String>(
              value: _jenisDokumen,
              items: ['Surat Jalan', 'Resi Pengambilan']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _jenisDokumen = val!),
            ),
            const SizedBox(height: 16),
            _buildLabel('Nomor Resi / Surat Jalan'),
            _buildTextField(
              controller: _nomorController,
              hint: 'Contoh: NVG-202609-001',
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: 16),
            _buildLabel('Tujuan Pengiriman'),
            _buildTextField(
              controller: _tujuanController,
              hint: 'Masukkan alamat tujuan lengkap',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStep2(AdminProvider provider) {
    final supirList = provider.masterData?.supirList ?? [];
    final barangList = provider.masterData?.barangList ?? [];

    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Detail Penugasan',
          icon: Icons.assignment_ind_outlined,
          children: [
            _buildLabel('Pilih Supir Pengantar'),
            _buildDropdown<String>(
              value: _selectedSupir,
              hint: 'Pilih supir yang bertugas',
              items: supirList
                  .map<DropdownMenuItem<String>>((s) => DropdownMenuItem(
                        value: s['id_user'].toString(),
                        child: Text(s['nama_lengkap'].toString()),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedSupir = val),
            ),
            const SizedBox(height: 16),
            _buildLabel('Pilih Barang'),
            _buildDropdown<String>(
              value: _selectedBarang == 'NEW_ITEM' ? null : _selectedBarang,
              hint: 'Pilih barang yang akan dikirim',
              items: [
                ...barangList.map<DropdownMenuItem<String>>((b) => DropdownMenuItem(
                      value: b['id_barang'].toString(),
                      child: Text('[${b['kode_barang']}] ${b['nama_barang']}'),
                    )),
                DropdownMenuItem(
                  value: 'NEW_ITEM',
                  child: Text('+ Tambah Barang Baru...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
              onChanged: (val) {
                if (val == 'NEW_ITEM') {
                  _showTambahBarangDialog(provider);
                } else {
                  setState(() => _selectedBarang = val);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Jumlah Item (Unit/Box)'),
            _buildTextField(
              controller: _jumlahController,
              hint: 'Masukkan total kuantitas',
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStep3(AdminProvider provider) {
    final supirList = provider.masterData?.supirList ?? [];
    final barangList = provider.masterData?.barangList ?? [];
    final supirName = supirList.firstWhere(
      (s) => s['id_user'].toString() == _selectedSupir,
      orElse: () => {'nama_lengkap': '-'},
    )['nama_lengkap'];
    final barangItem = barangList.firstWhere(
      (b) => b['id_barang'].toString() == _selectedBarang,
      orElse: () => {'kode_barang': '-', 'nama_barang': '-'},
    );

    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Ringkasan Dokumen',
          icon: Icons.preview_outlined,
          children: [
            _buildSummaryRow('Tipe Dokumen', _jenisDokumen),
            _buildSummaryRow('Nomor Resi', _nomorController.text),
            _buildSummaryRow('Tujuan', _tujuanController.text),
            const Divider(height: 24, color: AppColors.borderLight),
            _buildSummaryRow('Supir', supirName.toString()),
            _buildSummaryRow('Barang', '[${barangItem['kode_barang']}] ${barangItem['nama_barang']}'),
            _buildSummaryRow('Jumlah', '${_jumlahController.text} Unit'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pastikan seluruh data sudah benar sebelum mengirim dokumen.',
                  style: TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AdminProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Kembali'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        if (_validateStep(_currentStep)) {
                          setState(() => _currentStep++);
                        } else {
                          CustomSnackbar.show(context, 'Harap lengkapi seluruh data terlebih dahulu!', isError: true);
                        }
                      } else {
                        _simpanDokumen();
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                  : Text(_currentStep < 2 ? 'Lanjutkan' : 'Simpan & Tugaskan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.success.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dokumen Berhasil Dibuat!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tugas telah dikirim ke supir yang ditugaskan',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahBarangDialog(AdminProvider provider) {
    final TextEditingController namaCtrl = TextEditingController();
    final TextEditingController kategoriCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          backgroundColor: AppColors.surface,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tambah Barang Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                _buildLabel('Nama Barang'),
                _buildTextField(controller: namaCtrl, hint: 'Misal: Navagreen Facial Wash', icon: Icons.inventory_2_outlined),
                const SizedBox(height: 16),
                _buildLabel('Kategori Barang'),
                _buildTextField(controller: kategoriCtrl, hint: 'Misal: Sabun Wajah', icon: Icons.category_outlined),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (namaCtrl.text.trim().isEmpty || kategoriCtrl.text.trim().isEmpty) {
                                  CustomSnackbar.show(context, 'Harap isi nama dan kategori barang', isError: true);
                                  return;
                                }
                                setStateDialog(() => isSaving = true);
                                final result = await provider.tambahBarang(namaCtrl.text.trim(), kategoriCtrl.text.trim());
                                setStateDialog(() => isSaving = false);
                                
                                if (mounted) {
                                  Navigator.pop(context);
                                  if (result['status'] == 'success') {
                                    CustomSnackbar.show(context, '✅ Barang berhasil ditambahkan!');
                                    // Select the new item
                                    setState(() {
                                      _selectedBarang = result['data']['id_barang'].toString();
                                    });
                                  } else {
                                    CustomSnackbar.show(context, result['message'] ?? 'Gagal menambahkan barang', isError: true);
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                            : const Text('Simpan Barang'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE BUILDERS
  // ============================================================
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppGlass.elevatedCard(radius: AppRadius.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 28, color: AppColors.borderLight),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 24.0 : 0),
          child: Icon(icon, size: 20, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    String? hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(),
      child: DropdownButton<T>(
        isExpanded: true,
        value: value,
        hint: hint != null ? Text(hint, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)) : null,
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        dropdownColor: AppColors.surface,
        underline: const SizedBox(),
        isDense: true,
      ),
    );
  }
}
