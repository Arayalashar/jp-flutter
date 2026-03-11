import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuatDokumenScreen extends StatefulWidget {
  @override
  _BuatDokumenScreenState createState() => _BuatDokumenScreenState();
}

class _BuatDokumenScreenState extends State<BuatDokumenScreen> {
  // Controller untuk input teks
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  // Variabel untuk Dropdown
  String _jenisDokumen = 'Resi Pengiriman';
  String? _selectedSupir;
  String? _selectedBarang;

  // List untuk menampung data dari API
  List _listSupir = [];
  List _listBarang = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMasterData(); // Ambil data saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil data Supir dan Barang dari PHP
  Future<void> _fetchMasterData() async {
    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_master_data.php');
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listSupir = data['data_supir'];
          _listBarang = data['data_barang'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error ambil data: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk mengirim data form ke PHP
  Future<void> _simpanDokumen() async {
    if (_selectedSupir == null || _selectedBarang == null || _nomorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap lengkapi semua data!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('http://127.0.0.1/JP/api_buat_dokumen.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jenis_dokumen": _jenisDokumen,
          "nomor_dokumen": _nomorController.text,
          "tujuan": _tujuanController.text,
          "id_supir": _selectedSupir,
          "id_barang": _selectedBarang,
          "jumlah": _jumlahController.text,
          "id_admin": "1", // Sementara kita hardcode ID Admin (misal id 1)
        }),
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke Dashboard setelah sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Gagal menyimpan data."), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buat Dokumen Baru"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tipe Dokumen", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _jenisDokumen,
                    items: ['Resi Pengambilan', 'Resi Pengiriman', 'Surat Jalan']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _jenisDokumen = val!),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),

                  Text("Nomor Resi / Surat Jalan", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _nomorController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Contoh: FLUTTER-001"),
                  ),
                  SizedBox(height: 16),

                  Text("Tujuan Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _tujuanController,
                    maxLines: 2,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Masukkan alamat tujuan"),
                  ),
                  SizedBox(height: 16),

                  Text("Pilih Supir", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedSupir,
                    hint: Text("-- Pilih Supir --"),
                    items: _listSupir.map<DropdownMenuItem<String>>((supir) {
                      return DropdownMenuItem<String>(
                        value: supir['id_user'].toString(),
                        child: Text(supir['nama_lengkap']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSupir = val),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),

                  Text("Pilih Barang", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedBarang,
                    hint: Text("-- Pilih Barang --"),
                    items: _listBarang.map<DropdownMenuItem<String>>((barang) {
                      return DropdownMenuItem<String>(
                        value: barang['id_barang'].toString(),
                        child: Text("[${barang['kode_barang']}] ${barang['nama_barang']}"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBarang = val),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),

                  Text("Jumlah Item (Unit/Box)", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _simpanDokumen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("Simpan & Tugaskan Supir", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}