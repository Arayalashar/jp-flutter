import 'package:flutter/material.dart';
import '../models/gudang_model.dart';
import '../repositories/gudang_repository.dart';

class GudangProvider extends ChangeNotifier {
  final GudangRepository _repository = GudangRepository();
  
  List<GudangModel> _tugasList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GudangModel> get tugasList => _tugasList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTugas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tugasList = await _repository.fetchTugas();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> selesaikanPacking(String idDokumen, String idKaryawan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.selesaikanPacking(idDokumen, idKaryawan);

      if (result['status'] == 'success') {
        await fetchTugas(); // Refresh data
      } else {
        _isLoading = false;
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': 'Terjadi kesalahan sistem.'};
    }
  }
}
