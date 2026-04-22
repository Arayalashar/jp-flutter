import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuatDokumenScreen extends StatefulWidget {
  const BuatDokumenScreen({super.key});

  @override
  State<BuatDokumenScreen> createState() => _BuatDokumenScreenState();
}

class _BuatDokumenScreenState extends State<BuatDokumenScreen> {
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  String _jenisDokumen = 'Resi Pengiriman';
  String? _selectedSupir;
  String? _selectedBarang;
  List<dynamic> _listSupir = [];
  List<dynamic> _listBarang = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  @override
  void dispose() {
    _nomorController.dispose();
    _tujuanController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _fetchMasterData() async {
    try {
      var url = Uri.parse('https://apiptjakhipasaribawa.lovestoblog.com/api_master_data.php');
      var response = await http.get(url);
      
      if (!mounted) return;

      var data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        setState(() {
          _listSupir = data['data_supir'] ?? [];
          _listBarang = data['data_barang'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(data['message'] ?? 'Gagal memuat data master', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Gagal terhubung ke server. Pastikan XAMPP menyala.", isError: true);
    }
  }

  Future<void> _simpanDokumen() async {
    if (_selectedSupir == null ||
        _selectedBarang == null ||
        _nomorController.text.trim().isEmpty ||
        _tujuanController.text.trim().isEmpty ||
        _jumlahController.text.trim().isEmpty) {
      _showSnackBar("Harap lengkapi seluruh form data!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('https://apiptjakhipasaribawa.lovestoblog.com/api_buat_dokumen.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jenis_dokumen": _jenisDokumen,
          "nomor_dokumen": _nomorController.text.trim(),
          "tujuan": _tujuanController.text.trim(),
          "id_supir": _selectedSupir,
          "id_barang": _selectedBarang,
          "jumlah": _jumlahController.text.trim(),
          "id_admin": "1", 
        }),
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar(data['message'], isError: false);
        Navigator.pop(context); 
      } else {
        _showSnackBar(data['message'], isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal menyimpan data. Periksa koneksi server.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text(
          'Buat Dokumen Baru',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534), // Berubah ke Hijau Navagreen Utama
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF166534)), // Berubah ke Hijau
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'Informasi Dokumen',
                    icon: Icons.description_outlined,
                    children: [
                      _buildLabel('Tipe Dokumen'),
                      _buildDropdown<String>(
                        value: _jenisDokumen,
                        items: ['Resi Pengambilan', 'Resi Pengiriman', 'Surat Jalan']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _jenisDokumen = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Nomor Resi / Surat Jalan'),
                      _buildTextField(
                        controller: _nomorController,
                        hint: 'Contoh: FLUTTER-001',
                        icon: Icons.tag_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Tujuan Pengiriman'),
                      _buildTextField(
                        controller: _tujuanController,
                        hint: 'Masukkan alamat tujuan secara lengkap',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildSectionCard(
                    title: 'Detail Penugasan',
                    icon: Icons.assignment_ind_outlined,
                    children: [
                      _buildLabel('Pilih Supir Pengantar'),
                      _buildDropdown<String>(
                        value: _selectedSupir,
                        hint: 'Pilih supir yang bertugas',
                        items: _listSupir
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
                        value: _selectedBarang,
                        hint: 'Pilih barang yang akan dikirim',
                        items: _listBarang
                            .map<DropdownMenuItem<String>>((b) => DropdownMenuItem(
                                  value: b['id_barang'].toString(),
                                  child: Text('[${b['kode_barang']}] ${b['nama_barang']}'),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedBarang = val),
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
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton.icon(
                    onPressed: _simpanDokumen,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text(
                      'Simpan & Tugaskan Supir',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534), // Berubah ke Hijau Navagreen Utama
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Aksen Hijau Sangat Lembut (Tailwind green-50)
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF166534), size: 20), // Ikon Hijau
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569), 
        ),
      ),
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
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w400),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 24.0 : 0), 
          child: Icon(icon, size: 20, color: Colors.grey.shade400),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5), // Garis fokus hijau
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
    return DropdownButtonFormField<T>(
      value: value,
      hint: hint != null
          ? Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13))
          : null,
      items: items,
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5), // Garis fokus hijau
        ),
      ),
    );
  }
}