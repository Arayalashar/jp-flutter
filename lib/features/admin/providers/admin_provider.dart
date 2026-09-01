import 'package:flutter/material.dart';
import '../models/master_data_model.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  MasterDataModel? _masterData;
  Map<String, dynamic>? _laporanData;
  List<dynamic> _riwayatList = [];

  bool _isLoading = false;
  String? _errorMessage;

  MasterDataModel? get masterData => _masterData;
  Map<String, dynamic>? get laporanData => _laporanData;
  List<dynamic> get riwayatList => _riwayatList;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMasterData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _masterData = await _repository.fetchMasterData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> buatDokumen({
    required String jenisDokumen,
    required String nomorDokumen,
    required String tujuan,
    required String idSupir,
    required String idBarang,
    required String jumlah,
    required String idAdmin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.buatDokumen(
        jenisDokumen: jenisDokumen,
        nomorDokumen: nomorDokumen,
        tujuan: tujuan,
        idSupir: idSupir,
        idBarang: idBarang,
        jumlah: jumlah,
        idAdmin: idAdmin,
      );
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': 'Terjadi kesalahan saat menyimpan dokumen.'};
    }
  }

  Future<void> fetchLaporan(String filter) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.fetchLaporan(filter);
      if (response['status'] == 'success') {
        _laporanData = response;
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat laporan';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRiwayat() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.fetchRiwayatPemeriksaan();
      if (response['status'] == 'success') {
        _riwayatList = response['data'] ?? [];
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat riwayat';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> tambahBarang(String namaBarang, String kategori) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.tambahBarang(namaBarang, kategori);
      if (result['status'] == 'success') {
        await fetchMasterData(); // Refresh data after adding
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': 'Terjadi kesalahan sistem.'};
    }
  }
}
