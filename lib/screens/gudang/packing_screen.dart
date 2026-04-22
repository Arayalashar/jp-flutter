import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PackingScreen extends StatefulWidget {
  final String idGudang;
  const PackingScreen({super.key, required this.idGudang});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  List _listPacking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTugasPacking();
  }

  Future<void> _fetchTugasPacking() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('https://jpapi.alwaysdata.net/api_tugas_gudang.php');
      var response = await http.get(url);
      
      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listPacking = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(data['message'] ?? "Gagal memuat tugas", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Gagal terhubung ke server. Periksa koneksi Anda.", isError: true);
    }
  }

  Future<void> _selesaikanPacking(String idDokumen) async {
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('https://jpapi.alwaysdata.net/api_selesai_packing.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_dokumen": idDokumen,
          "id_karyawan": widget.idGudang,
        }),
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar("Barang Siap Dikirim!", isError: false);
        _fetchTugasPacking(); 
      } else {
        _showSnackBar(data['message'], isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error koneksi jaringan!", isError: true);
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

  void _konfirmasiPacking(String idDokumen, String namaBarang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Konfirmasi Packing",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          "Apakah barang '$namaBarang' sudah selesai dipacking dan siap diserahkan ke Supir?",
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569), // Slate 600
            ),
            child: const Text("Belum", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _selesaikanPacking(idDokumen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534), // Hijau Navagreen
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("Sudah Siap", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          "Tugas Sortir & Packing",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534), // Hijau Navagreen
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
          : RefreshIndicator(
              onRefresh: _fetchTugasPacking,
              color: const Color(0xFF166534),
              child: _listPacking.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _listPacking.length,
                      itemBuilder: (context, index) {
                        var item = _listPacking[index];
                        return _buildPackingCard(item);
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
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Hore! Tidak ada tugas packing.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk mengecek tugas baru',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackingCard(Map<String, dynamic> item) {
    bool isDone = item['status_pengiriman'] == 'Siap Dikirim';
    String statusText = isDone ? 'Siap Dikirim' : 'Menunggu';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : Colors.white, // Hijau sangat pucat jika selesai
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? const Color(0xFFBBF7D0) : Colors.transparent, // Border hijau lembut jika selesai
          width: 1,
        ),
        boxShadow: [
          if (!isDone) // Hilangkan bayangan jika selesai agar terlihat "tenggelam"
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
          // Header: Nomor Resi & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['nomor_dokumen'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: isDone ? const Color(0xFF059669) : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          
          // Konten Utama
          _buildInfoRow(Icons.inventory_2_outlined, "Barang:", "[${item['kode_barang']}] ${item['nama_barang']}", isDone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.tag_rounded, "Jumlah:", "${item['jumlah_packing']} Unit", isDone, isBoldValue: true),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "Tujuan:", item['tujuan_pengiriman'], isDone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline_rounded, "Supir:", item['nama_supir'] ?? '-', isDone),
          
          const SizedBox(height: 20),
          
          // Tombol Aksi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isDone 
                  ? null 
                  : () => _konfirmasiPacking(item['id_dokumen'].toString(), item['nama_barang']),
              icon: Icon(
                isDone ? Icons.check_circle_rounded : Icons.check_box_outlined, 
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                isDone ? "SUDAH DIPACKING" : "Selesai Packing", 
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534), // Hijau Navagreen Utama
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF059669).withOpacity(0.8), // Emerald 600 saat mati
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDone, {bool isBoldValue = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: isDone ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 8),
        Text(
          "$label ",
          style: TextStyle(
            fontSize: 13, 
            color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF64748B), 
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13, 
              color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF1E293B), 
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}