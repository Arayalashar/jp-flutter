import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin/buat_dokumen_screen.dart';
import 'admin/laporan_screen.dart';
import 'admin/riwayat_pemeriksaan_screen.dart';
import 'supir/tugas_supir_screen.dart';
import 'spv/pemeriksaan_screen.dart';
import 'gudang/packing_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  final String nama;
  final String idUser; // TAMBAHKAN INI

  // TAMBAHKAN required this.idUser di dalam kurung ini
  DashboardScreen({required this.role, required this.nama, required this.idUser});

  // Fungsi untuk menentukan menu apa saja yang muncul berdasarkan role
  List<Widget> _buildMenus(BuildContext context) {
    if (role == 'admin') {
      return [
        _buildMenuCard(context, Icons.note_add, "Pembuatan Dokumen", Colors.blue),
        _buildMenuCard(context, Icons.bar_chart, "Laporan Operasional", Colors.purple),
        _buildMenuCard(context, Icons.fact_check, "Riwayat Pemeriksaan", Colors.teal), // MENU BARU
      ];
    } else if (role == 'supervisor') {
      return [
        _buildMenuCard(context, Icons.inventory_outlined, "Pemeriksaan Barang", Colors.orange),
      ];
    } else if (role == 'karyawan_gudang') {
      return [
        _buildMenuCard(context, Icons.layers, "Sortir & Packing", Colors.brown),
      ];
    } else if (role == 'supir') {
      return [
        _buildMenuCard(context, Icons.local_shipping, "Tugas Pengiriman", Colors.red),
      ];
    }
    return [];
  }

  // Desain kotak menu (Card)
  Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Tambahkan logika navigasi di sini!
          if (title == "Pembuatan Dokumen") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuatDokumenScreen()),
            );
          } else if (title == "Laporan Operasional") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LaporanScreen()),
            );
            } else if (title == "Tugas Pengiriman") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TugasSupirScreen(idSupir: idUser)),
            );
            } else if (title == "Pemeriksaan Barang") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PemeriksaanScreen(idSpv: idUser)),
            );
            } else if (title == "Laporan Operasional") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LaporanScreen()),
            );
          } else if (title == "Riwayat Pemeriksaan") { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiwayatPemeriksaanScreen()),
            );
            } else if (title == "Pemeriksaan Barang") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PemeriksaanScreen(idSpv: idUser)),
            );
          } else if (title == "Sortir & Packing") { // TAMBAHKAN INI
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PackingScreen(idGudang: idUser)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Membuka menu: $title...")),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard PT. Jakhi Pasaribawa"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white, // Warna teks appbar
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Fungsi Logout: kembali ke halaman login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            tooltip: 'Keluar',
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $nama!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Login sebagai: ${role.toUpperCase()}",
              style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            
            // GridView untuk menampilkan kotak-kotak menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 kotak per baris
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _buildMenus(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}