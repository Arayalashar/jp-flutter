import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanScreen extends StatefulWidget {
  @override
  _LaporanScreenState createState() => _LaporanScreenState();
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
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_laporan.php');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _summary = data['summary'];
          _listDokumen = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // Desain Kotak Summary
  Widget _buildSummaryBox(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color, width: 1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // Menentukan warna badge status
  Color _getStatusColor(String status) {
    if (status == 'Sampai Tujuan') return Colors.green;
    if (status == 'Gagal Kirim') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Operasional"),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Bagian Atas: 3 Kotak Summary
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildSummaryBox("Total", _summary['total'].toString(), Colors.blue),
                      SizedBox(width: 8),
                      _buildSummaryBox("Selesai", _summary['selesai'].toString(), Colors.green),
                      SizedBox(width: 8),
                      _buildSummaryBox("Gagal", _summary['gagal'].toString(), const Color.fromARGB(255, 237, 39, 25)),
                    ],
                  ),
                ),
                Divider(thickness: 2),
                
                // Bagian Bawah: List View Detail Dokumen
                Expanded(
                  child: _listDokumen.isEmpty
                      ? Center(child: Text("Belum ada data dokumen."))
                      : ListView.builder(
                          itemCount: _listDokumen.length,
                          itemBuilder: (context, index) {
                            var doc = _listDokumen[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.description, color: Colors.purple[300], size: 40),
                                title: Text(doc['nomor_dokumen'], style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tipe: ${doc['jenis_dokumen']}"),
                                    Text("Supir: ${doc['nama_supir'] ?? 'Belum ada'}"),
                                    Text("Tujuan: ${doc['tujuan_pengiriman']}"),
                                    SizedBox(height: 8),
                                    
                                    // Menampilkan Tanggal Buat
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          "Dibuat: ${doc['tanggal_buat'] ?? '-'}", 
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700])
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    
                                    // Menampilkan Waktu Update Terakhir dari Supir
                                    Row(
                                      children: [
                                        Icon(Icons.update, size: 12, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          "Update: ${doc['waktu_update'] ?? 'Belum ada update'}", 
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700])
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(doc['status_pengiriman']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    doc['status_pengiriman'],
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}