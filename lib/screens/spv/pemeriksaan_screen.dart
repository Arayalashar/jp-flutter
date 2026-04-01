import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PemeriksaanScreen extends StatefulWidget {
  final String idSpv;
  PemeriksaanScreen({required this.idSpv});

  @override
  _PemeriksaanScreenState createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  List _listAntrean = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAntrean();
  }

  Future<void> _fetchAntrean() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_resi_pengambilan.php');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listAntrean = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simpanPemeriksaan(Map item, int bagus, int rusak, String status, String catatan) async {
    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_periksa_barang.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_dokumen": item['id_dokumen'],
          "id_barang": item['id_barang'],
          "id_spv": widget.idSpv,
          "jumlah_diharapkan": item['jumlah_diharapkan'],
          "jumlah_bagus": bagus,
          "jumlah_rusak": rusak,
          "status_pemeriksaan": status,
          "catatan": catatan
        }),
      );

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
        _fetchAntrean(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showPeriksaDialog(Map item) {
    TextEditingController _bagusCtrl = TextEditingController(text: item['jumlah_diharapkan'].toString());
    TextEditingController _rusakCtrl = TextEditingController(text: "0");
    TextEditingController _catatanCtrl = TextEditingController();
    String _status = "Lengkap";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Pemeriksaan Fisik"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Produk: ${item['nama_barang']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Jumlah di Resi: ${item['jumlah_diharapkan']} Unit", style: TextStyle(color: Colors.blue)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _bagusCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Jumlah Bagus", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _rusakCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Jumlah Rusak / Cacat", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: ['Lengkap', 'Kurang', 'Rusak'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setStateDialog(() => _status = val!),
                      decoration: InputDecoration(labelText: "Status Keseluruhan", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _catatanCtrl,
                      decoration: InputDecoration(labelText: "Catatan (Opsional)", border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
                ElevatedButton(
                  onPressed: () {
                    int bagus = int.tryParse(_bagusCtrl.text) ?? 0;
                    int rusak = int.tryParse(_rusakCtrl.text) ?? 0;
                    _simpanPemeriksaan(item, bagus, rusak, _status, _catatanCtrl.text);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                  child: Text("Simpan Hasil", style: TextStyle(color: Colors.white)),
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
      appBar: AppBar(title: Text("Pemeriksaan Barang"), backgroundColor: Colors.orange[700], foregroundColor: Colors.white),
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listAntrean.isEmpty
              ? Center(child: Text("Belum ada barang datang dari produsen."))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _listAntrean.length,
                  itemBuilder: (context, index) {
                    var item = _listAntrean[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nomor_dokumen'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Divider(),
                            Text("Barang: ${item['nama_barang']}", style: TextStyle(fontSize: 16)),
                            Text("Jumlah: ${item['jumlah_diharapkan']} Unit", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                            Text("Supir: ${item['supir'] ?? '-'}"),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showPeriksaDialog(item),
                                icon: Icon(Icons.fact_check, color: Colors.white),
                                label: Text("Periksa Fisik", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
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