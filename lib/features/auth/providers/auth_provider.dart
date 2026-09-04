import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id_user');
    final nama = prefs.getString('nama_lengkap');
    final role = prefs.getString('role');

    if (id != null && nama != null && role != null) {
      _currentUser = UserModel(idUser: id, namaLengkap: nama, role: role);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.login(username, password);

    if (result['success'] == true) {
      _currentUser = result['user'];
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_user', _currentUser!.idUser);
      await prefs.setString('nama_lengkap', _currentUser!.namaLengkap);
      await prefs.setString('role', _currentUser!.role);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> updateProfile(String namaLengkap, String password) async {
    if (_currentUser == null) return {'success': false, 'message': 'Belum login'};

    _isLoading = true;
    notifyListeners();

    final result = await _repository.updateProfile(_currentUser!.idUser, namaLengkap, password);

    if (result['success'] == true) {
      _currentUser = result['user'];
      
      // Update session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama_lengkap', _currentUser!.namaLengkap);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }
}
