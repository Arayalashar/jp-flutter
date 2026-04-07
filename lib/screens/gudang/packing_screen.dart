import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PackingScreen extends StatefulWidget {
  final String idGudang;
  PackingScreen({required this.idGudang});

  @override
  _PackingScreenState createState() => _PackingScreenState();
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
      var url = Uri.parse('http://127.0.0.1/JP/api_tugas_gudang.php');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listPacking = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // FUNGSI YANG SUDAH DIPERBAIKI (MENGGUNAKAN API KHUSUS GUDANG)
  Future<void> _selesaikanPacking(String idDokumen) async {
    setState(() => _isLoading = true);

    try {
      // 1. Mengarah ke API yang benar
      var url = Uri.parse('http://127.0.0.1/JP/api_selesai_packing.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_dokumen": idDokumen,
          "id_karyawan": widget.idGudang, // 2. Mengirim ID karyawan untuk tabel sortir_log
        }),
      );

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Barang Siap Dikirim!"), backgroundColor: Colors.green)
        );
        // 3. Me-refresh data. Barang yang sudah dipacking akan otomatis hilang dari layar!
        _fetchTugasPacking(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red)
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error koneksi jaringan!"), backgroundColor: Colors.red)
      );
      setState(() => _isLoading = false);
    }
  }

  // Dialog Konfirmasi sebelum mengubah status
  void _konfirmasiPacking(String idDokumen, String namaBarang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Packing"),
        content: Text("Apakah barang '$namaBarang' sudah selesai dipacking dan siap diserahkan ke Supir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Belum")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _selesaikanPacking(idDokumen); // Jalankan fungsi update
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[600]),
            child: Text("Sudah Siap", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tugas Sortir & Packing"), backgroundColor: Colors.brown[600], foregroundColor: Colors.white),
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listPacking.isEmpty
              ? Center(child: Text("Hore! Tidak ada barang yang perlu dipacking."))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _listPacking.length,
                  itemBuilder: (context, index) {
                    var item = _listPacking[index];
                    
                    // 1. Cek apakah barang ini sudah selesai dipacking
                    bool isDone = item['status_pengiriman'] == 'Siap Dikirim';
                    String statusText = isDone ? 'Siap Dikirim' : 'Menunggu';

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: isDone ? 1 : 3, // Card jadi lebih datar kalau sudah selesai
                      color: isDone ? Colors.green[50] : Colors.white, // Background sedikit hijau kalau selesai
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['nomor_dokumen'], 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone ? TextDecoration.lineThrough : null // Coret teks jika selesai
                                  )
                                ),
                                
                                // 2. BADGE STATUS DINAMIS (Warna berubah sesuai status)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDone ? Colors.green[100] : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDone ? Colors.green : Colors.orange, width: 1),
                                  ),
                                  child: Text(
                                    statusText, 
                                    style: TextStyle(
                                      color: isDone ? Colors.green[800] : Colors.orange[800], 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Text("Barang: [${item['kode_barang']}] ${item['nama_barang']}", style: TextStyle(fontSize: 16)),
                            Text("Jumlah: ${item['jumlah_packing']} Unit", style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text("Tujuan: ${item['tujuan_pengiriman']}", style: TextStyle(color: Colors.grey[700])),
                            Text("Diserahkan ke Supir: ${item['nama_supir'] ?? '-'}"),
                            SizedBox(height: 16),
                            
                            // 3. TOMBOL DINAMIS (Terkunci dan berubah hijau jika selesai)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isDone 
                                    ? null // Jika isDone true, tombol mati (tidak bisa diklik)
                                    : () => _konfirmasiPacking(item['id_dokumen'].toString(), item['nama_barang']),
                                icon: Icon(isDone ? Icons.check_circle : Icons.check_box, color: Colors.white),
                                label: Text(isDone ? "SUDAH DIPACKING" : "Selesai Packing", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown[600],
                                  disabledBackgroundColor: Colors.green[500], // Warna tombol saat terkunci (hijau)
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}