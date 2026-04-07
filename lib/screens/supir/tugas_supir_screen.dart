import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TugasSupirScreen extends StatefulWidget {
  final String idSupir;

  TugasSupirScreen({required this.idSupir});

  @override
  _TugasSupirScreenState createState() => _TugasSupirScreenState();
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
      var url = Uri.parse('http://127.0.0.1/JP/api_tugas_supir.php?id_supir=${widget.idSupir}');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listTugas = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk Update Status API
  Future<void> _updateStatus(String idDokumen, String statusBaru, String keterangan) async {
    Navigator.pop(context); // Tutup dialog dulu
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_update_status.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_dokumen": idDokumen,
          "status": statusBaru,
          "keterangan": keterangan
        }),
      );

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
        _fetchTugas(); // Refresh data layar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Pop-up Dialog untuk input update status
  void _showUpdateDialog(Map<String, dynamic> tugas) {
    String _selectedStatus = "Dalam Perjalanan";
    TextEditingController _ketController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Update Status\n${tugas['nomor_dokumen']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tujuan: ${tugas['tujuan_pengiriman']}"),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ['Dalam Perjalanan', 'Sampai Tujuan', 'Gagal Kirim']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => _selectedStatus = val!),
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Status Baru"),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _ketController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Nama Penerima / Alasan Gagal"),
                    maxLines: 2,
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
                ElevatedButton(
                  onPressed: () => _updateStatus(tugas['id_dokumen'].toString(), _selectedStatus, _ketController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tugas Pengiriman"), backgroundColor: Colors.red[700], foregroundColor: Colors.white),
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listTugas.isEmpty
              ? Center(child: Text("Hore! Belum ada tugas untuk Anda."))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _listTugas.length,
                  itemBuilder: (context, index) {
                    var tugas = _listTugas[index];
                    bool isSelesai = tugas['status_pengiriman'] == 'Sampai Tujuan';

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
                                Text(tugas['nomor_dokumen'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelesai ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(tugas['status_pengiriman'], style: TextStyle(color: Colors.white, fontSize: 12)),
                                )
                              ],
                            ),
                            Divider(),
                            Text("Tipe: ${tugas['jenis_dokumen']}"),
                            SizedBox(height: 4),
                            Text("Tujuan: ${tugas['tujuan_pengiriman']}", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            if (!isSelesai) // Tombol hanya muncul kalau belum selesai
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showUpdateDialog(tugas),
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text("Update Status", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
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