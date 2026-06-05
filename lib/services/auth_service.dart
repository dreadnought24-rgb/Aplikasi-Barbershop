import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final String role;
  final int userId;

  AuthResult({
    required this.success,
    required this.message,
    this.role = '',
    this.userId = 0,
  });
}

class AuthService {
  static Future<AuthResult> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login.php'),
            body: {'username': username, 'password': password},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return AuthResult(
            success: true,
            message: data['message'] ?? 'Login berhasil',
            role: data['role'] ?? '',
            userId: data['id'] ?? 0,
          );
        } else {
          return AuthResult(
            success: false,
            message: data['message'] ?? 'Login gagal',
          );
        }
      } else {
        return AuthResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message:
            'Tidak dapat terhubung ke server ($e). Pastikan XAMPP berjalan.',
      );
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String nama,
    required String noHp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/register.php'),
            body: {
              'username': username,
              'password': password,
              'nama': nama,
              'no_hp': noHp,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Register gagal',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server ($e). Pastikan XAMPP berjalan.',
      };
    }
  }
}
