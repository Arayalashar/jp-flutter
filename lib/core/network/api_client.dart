import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const int _timeoutSeconds = 15;

  static Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', ...?headers},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'error', 'message': 'Format respons tidak valid'};
      } catch (e) {
        if (kDebugMode) {
          print('JSON Decode Error: $e\nResponse Body: ${response.body}');
        }
        return {'status': 'error', 'message': 'Gagal membaca respons dari server'};
      }
    } else {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan server (Kode: ${response.statusCode})',
      };
    }
  }

  static Map<String, dynamic> _handleError(dynamic e) {
    if (kDebugMode) {
      print('API Error: $e');
    }
    return {
      'status': 'error',
      'message': 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
    };
  }
}
