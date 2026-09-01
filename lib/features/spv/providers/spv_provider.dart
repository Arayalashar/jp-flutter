import 'package:flutter/material.dart';
import '../models/antrean_model.dart';
import '../repositories/spv_repository.dart';

class SpvProvider extends ChangeNotifier {
  final SpvRepository _repository = SpvRepository();
  
  List<AntreanModel> _antreanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AntreanModel> get antreanList => _antreanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAntrean() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _antreanList = await _repository.fetchAntrean();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> simpanPemeriksaan({
    required AntreanModel item,
    required String idSpv,
    required int jumlahBagus,
    required int jumlahRusak,
    required String status,
    required String catatan,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.simpanPemeriksaan(
        idDokumen: item.idDokumen,
        idBarang: item.idBarang,
        idSpv: idSpv,
        jumlahDiharapkan: item.jumlahDiharapkan,
        jumlahBagus: jumlahBagus,
        jumlahRusak: jumlahRusak,
        status: status,
        catatan: catatan,
      );

      if (result['status'] == 'success') {
        await fetchAntrean(); // Refresh the list
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
