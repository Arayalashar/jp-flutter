import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatPemeriksaanScreen extends StatefulWidget {
  const RiwayatPemeriksaanScreen({super.key});

  @override
  State<RiwayatPemeriksaanScreen> createState() => _RiwayatPemeriksaanScreenState();
}

class _RiwayatPemeriksaanScreenState extends State<RiwayatPemeriksaanScreen> {
  List _listRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_riwayat_pemeriksaan.php');
      var response = await http.get(url);
      
      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listRiwayat = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError(data['message'] ?? "Gagal memuat data riwayat.");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Gagal terhubung ke server. Periksa koneksi Anda.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Desain warna status modern (Soft Background + Solid Text)
  Color _getStatusTextColor(String status) {
    if (status == 'Lengkap') return const Color(0xFF059669); // Emerald 600
    if (status == 'Kurang') return const Color(0xFFD97706); // Amber 600
    if (status == 'Rusak') return const Color(0xFFDC2626); // Red 600
    return const Color(0xFF475569); // Slate 600
  }

  Color _getStatusBgColor(String status) {
    if (status == 'Lengkap') return const Color(0xFFD1FAE5); // Emerald 100
    if (status == 'Kurang') return const Color(0xFFFEF3C7); // Amber 100
    if (status == 'Rusak') return const Color(0xFFFEE2E2); // Red 100
    return const Color(0xFFF1F5F9); // Slate 100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          "Riwayat Pemeriksaan SPV",
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
              onRefresh: _fetchRiwayat,
              color: const Color(0xFF166534),
              child: _listRiwayat.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _listRiwayat.length,
                      itemBuilder: (context, index) {
                        var item = _listRiwayat[index];
                        return _buildRiwayatCard(item);
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
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat pemeriksaan',
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

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final status = item['status_pemeriksaan'] ?? 'Unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
          // Header Row: Kode Barang & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "[${item['kode_barang']}] ${item['nama_barang']}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusTextColor(status),
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
          
          // Informasi Pemeriksa & Waktu
          _buildInfoRow(Icons.person_outline_rounded, "Pemeriksa (SPV):", item['nama_spv'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_rounded, "Tanggal Periksa:", item['tanggal_pemeriksaan'] ?? '-'),
          
          const SizedBox(height: 16),
          
          // Metrik Barang
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem("Diharapkan", item['jumlah_datang'].toString(), const Color(0xFF475569)),
                _buildMetricItem("Bagus", item['jumlah_bagus'].toString(), const Color(0xFF059669)),
                _buildMetricItem("Rusak", item['jumlah_rusak'].toString(), const Color(0xFFDC2626)),
              ],
            ),
          ),
          
          // Bagian Catatan (Jika ada)
          if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber 50
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEF3C7)), // Amber 100
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Catatan: ${item['catatan']}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E), // Amber 900
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          "$label ",
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, color: valueColor, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}