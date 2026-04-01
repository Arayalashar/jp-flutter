import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatPemeriksaanScreen extends StatefulWidget {
  @override
  _RiwayatPemeriksaanScreenState createState() => _RiwayatPemeriksaanScreenState();
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
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_riwayat_pemeriksaan.php');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listRiwayat = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // Memberi warna berdasarkan status barang
  Color _getStatusColor(String status) {
    if (status == 'Lengkap') return Colors.green;
    if (status == 'Kurang') return Colors.orange;
    if (status == 'Rusak') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Pemeriksaan SPV"),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listRiwayat.isEmpty
              ? Center(child: Text("Belum ada riwayat pemeriksaan dari SPV."))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _listRiwayat.length,
                  itemBuilder: (context, index) {
                    var item = _listRiwayat[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "[${item['kode_barang']}] ${item['nama_barang']}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status_pemeriksaan']),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['status_pemeriksaan'],
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            Divider(),
                            Text("Pemeriksa (SPV): ${item['nama_spv'] ?? '-'}", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.fact_check_outlined, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("Tgl Periksa: ${item['tanggal_pemeriksaan'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Diharapkan: ${item['jumlah_datang']}", style: TextStyle(color: Colors.blue)),
                                Text("Bagus: ${item['jumlah_bagus']}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                Text("Rusak: ${item['jumlah_rusak']}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) ...[
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.yellow[100],
                                child: Text("Catatan: ${item['catatan']}", style: TextStyle(fontSize: 12)),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}