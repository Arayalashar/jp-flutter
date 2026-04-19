import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  Map<String, dynamic> _summary = {"total": 0, "selesai": 0, "gagal": 0};
  List _listDokumen = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_laporan.php');
      var response = await http.get(url);
      
      if (!mounted) return;

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _summary = data['summary'];
          _listDokumen = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError("Gagal memuat data laporan.");
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

  Color _getStatusColor(String status) {
    if (status == 'Sampai Tujuan') return const Color(0xFF059669); // Emerald-600
    if (status == 'Gagal Kirim') return const Color(0xFFDC2626); // Red-600
    return const Color(0xFFD97706); // Amber-600
  }

  Color _getStatusBg(String status) {
    if (status == 'Sampai Tujuan') return const Color(0xFFD1FAE5); // Emerald-100
    if (status == 'Gagal Kirim') return const Color(0xFFFEE2E2); // Red-100
    return const Color(0xFFFEF3C7); // Amber-100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      appBar: AppBar(
        title: const Text(
          'Laporan Operasional',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534), // Hijau Navagreen Utama
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF166534)),
            )
          : RefreshIndicator(
              onRefresh: _fetchLaporan,
              color: const Color(0xFF166534),
              child: Column(
                children: [
                  // ─── Summary Strip ─────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF166534),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Total Dokumen',
                          _summary['total'].toString(),
                          Colors.white,
                          textColor: const Color(0xFF166534),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Selesai',
                          _summary['selesai'].toString(),
                          Colors.white.withOpacity(0.15),
                          textColor: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Kendala',
                          _summary['gagal'].toString(),
                          Colors.white.withOpacity(0.15),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  // ─── List ──────────────────────────────────────
                  Expanded(
                    child: _listDokumen.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            itemCount: _listDokumen.length,
                            itemBuilder: (context, index) {
                              var doc = _listDokumen[index];
                              final status = doc['status_pengiriman'] ?? '-';
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(18),
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
                                    // Header Card (Nomor & Badge)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            doc['nomor_dokumen'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getStatusBg(status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: _getStatusColor(status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    
                                    // Konten Card
                                    _buildDocRow(Icons.description_outlined, doc['jenis_dokumen'] ?? '-'),
                                    const SizedBox(height: 6),
                                    _buildDocRow(Icons.person_outline_rounded, doc['nama_supir'] ?? 'Belum ada supir'),
                                    const SizedBox(height: 6),
                                    _buildDocRow(Icons.location_on_outlined, doc['tujuan_pengiriman'] ?? '-'),
                                    
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    ),
                                    
                                    // Footer Card (Waktu)
                                    Row(
                                      children: [
                                        _buildMetaChip(Icons.calendar_today_rounded, doc['tanggal_buat'] ?? '-'),
                                        const SizedBox(width: 16),
                                        _buildMetaChip(Icons.update_rounded, doc['waktu_update'] ?? 'Belum update'),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada data laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk memuat ulang',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bg, {required Color textColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: const Color(0xFF94A3B8)), // Slate-400
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569), // Slate-600
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}