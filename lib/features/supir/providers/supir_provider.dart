import 'package:flutter/material.dart';
import '../repositories/supir_repository.dart';

class SupirProvider extends ChangeNotifier {
  final SupirRepository _repository = SupirRepository();

  List<dynamic> _tugasList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get tugasList => _tugasList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTugas(String idSupir) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tugasList = await _repository.fetchTugas(idSupir);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateStatus({
    required String idDokumen, 
    required String status, 
    required String keterangan,
    required String idSupir,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.updateStatus(idDokumen, status, keterangan);
      
      if (result['status'] == 'success') {
        await fetchTugas(idSupir); // Refresh data
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
