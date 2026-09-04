import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Secara cerdas menentukan Base URL berdasarkan platform yang sedang berjalan
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/JP';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2/JP';
    } else {
      return 'http://localhost/JP';
    }
  }

  // Auth
  static String get login => '$baseUrl/api/auth/login.php';
  static String get updateProfile => '$baseUrl/api/auth/update_profile.php';

  // Notifikasi
  static String get getNotifikasi => '$baseUrl/api/notifikasi/get.php';
  static String get readNotifikasi => '$baseUrl/api/notifikasi/read.php';

  // Dokumen
  static String get buatDokumen => '$baseUrl/api/dokumen/buat.php';
  static String get masterData => '$baseUrl/api/dokumen/master_data.php';
  static String get tambahBarang => '$baseUrl/api/dokumen/tambah_barang.php';
  static String get laporan => '$baseUrl/api/dokumen/laporan.php';
  static String get dashboardStats => '$baseUrl/api/dokumen/dashboard_stats.php';

  // Pemeriksaan
  static String get periksaBarang => '$baseUrl/api/pemeriksaan/periksa.php';
  static String get riwayatPemeriksaan => '$baseUrl/api/pemeriksaan/riwayat.php';
  static String get resiPengambilan => '$baseUrl/api/pemeriksaan/resi_pengambilan.php';

  // Gudang
  static String get tugasGudang => '$baseUrl/api/gudang/tugas.php';
  static String get selesaiPacking => '$baseUrl/api/gudang/packing.php';

  // Supir
  static String get tugasSupir => '$baseUrl/api/supir/tugas.php';
  static String get updateStatus => '$baseUrl/api/supir/update_status.php';
}
