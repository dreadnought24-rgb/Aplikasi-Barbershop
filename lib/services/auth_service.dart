import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login.php"),
      body: {"username": username, "password": password},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String nama,
    required String noHp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register.php"),
      body: {
        "username": username,
        "password": password,
        "nama": nama,
        "no_hp": noHp,
      },
    );

    return jsonDecode(response.body);
  }
}
