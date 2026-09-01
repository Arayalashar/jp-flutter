import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await ApiClient.post(
      ApiConfig.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response['status'] == 'success') {
      return {
        'success': true,
        'user': UserModel.fromJson(response['data']),
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Login gagal',
      };
    }
  }
}
