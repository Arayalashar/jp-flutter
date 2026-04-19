import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TugasSupirScreen extends StatefulWidget {
  final String idSupir;

  const TugasSupirScreen({super.key, required this.idSupir});

  @override
  State<TugasSupirScreen> createState() => _TugasSupirScreenState();
}

class _TugasSupirScreenState extends State<TugasSupirScreen> {
  List _listTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTugas();
  }

  // Mengambil daftar tugas berdasarkan ID Supir
  Future<void> _fetchTugas() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('apiptjakhipasaribawa.lovestoblog.com');
      var response = await http.get(url);
      
      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listTugas = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(data['message'] ?? "Gagal memuat tugas.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Gagal terhubung ke server. Periksa koneksi Anda.", isError: true);
    }
  }

  // Fungsi untuk Update Status API
  Future<void> _updateStatus(String idDokumen, String statusBaru, String keterangan) async {
    Navigator.pop(context); // Tutup dialog dulu
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('apiptjakhipasaribawa.lovestoblog.com');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_dokumen": idDokumen,
          "status": statusBaru,
          "keterangan": keterangan
        }),
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar("Status berhasil diperbarui!", isError: false);
        _fetchTugas(); // Refresh data layar
      } else {
        _showSnackBar(data['message'], isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal memperbarui status.", isError: true);
      setState(() => _isLoading = false);
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

  // Styling Warna Status
  Color _getStatusTextColor(String status) {
    if (status == 'Sampai Tujuan') return const Color(0xFF059669); // Emerald 600
    if (status == 'Gagal Kirim') return const Color(0xFFDC2626); // Red 600
    return const Color(0xFF2563EB); // Blue 600 (Dalam Perjalanan / Pending)
  }

  Color _getStatusBgColor(String status) {
    if (status == 'Sampai Tujuan') return const Color(0xFFD1FAE5); // Emerald 100
    if (status == 'Gagal Kirim') return const Color(0xFFFEE2E2); // Red 100
    return const Color(0xFFDBEAFE); // Blue 100
  }

  // Pop-up Dialog untuk input update status (Desain Modern)
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
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Dialog
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF166534), size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              "Update Pengiriman",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Info Pengiriman
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tugas['nomor_dokumen'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tujuan: ${tugas['tujuan_pengiriman']}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Inputs
                      const Text("Status Terbaru", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                        items: ['Dalam Perjalanan', 'Sampai Tujuan', 'Gagal Kirim']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                        decoration: _dialogInputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text("Keterangan Tambahan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ketController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dialogInputDecoration(hint: "Nama Penerima / Alasan Gagal..."),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(tugas['id_dokumen'].toString(), selectedStatus, ketController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534), // Hijau Utama
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text("Simpan Status", style: TextStyle(fontWeight: FontWeight.w700)),
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

  InputDecoration _dialogInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          "Tugas Pengiriman",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534), // Hijau Navagreen Utama
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
          : RefreshIndicator(
              onRefresh: _fetchTugas,
              color: const Color(0xFF166534),
              child: _listTugas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _listTugas.length,
                      itemBuilder: (context, index) {
                        var tugas = _listTugas[index];
                        return _buildTugasCard(tugas);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Hore! Belum ada tugas untuk Anda.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk memuat ulang',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> tugas) {
    bool isSelesai = tugas['status_pengiriman'] == 'Sampai Tujuan';
    String statusText = tugas['status_pengiriman'] ?? 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelesai ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelesai ? const Color(0xFFBBF7D0) : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          if (!isSelesai)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tugas['nomor_dokumen'],
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w800, 
                    color: isSelesai ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(statusText),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: _getStatusTextColor(statusText),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          
          // Konten Info
          _buildInfoRow(Icons.description_outlined, "Tipe:", tugas['jenis_dokumen'], isSelesai),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "Tujuan:", tugas['tujuan_pengiriman'], isSelesai, isHighlight: true),
          
          // Tombol Update (Hanya jika belum selesai)
          if (!isSelesai) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateDialog(tugas),
                icon: const Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 20),
                label: const Text("Update Status", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534), // Hijau Navagreen
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isSelesai, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: isSelesai ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 8),
        Text(
          "$label ",
          style: TextStyle(
            fontSize: 13, 
            color: isSelesai ? const Color(0xFF94A3B8) : const Color(0xFF64748B), 
            fontWeight: FontWeight.w500
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13, 
              color: isSelesai ? const Color(0xFF94A3B8) : (isHighlight ? const Color(0xFF2563EB) : const Color(0xFF1E293B)), 
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}