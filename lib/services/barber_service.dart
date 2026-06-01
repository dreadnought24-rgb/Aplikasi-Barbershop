import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barber_model.dart';
import '../config/api_config.dart';

class BarberService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<BarberModel>> getBarber() async {
    final url = Uri.parse('$baseUrl/barber/get_barbers.php');

    print("URL: $url");

    final response = await http.get(url);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic>
                ? (decoded['data'] as List<dynamic>? ?? const [])
                : const []);

      return data
          .whereType<Map<String, dynamic>>()
          .map(BarberModel.fromJson)
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil data barber\n'
        'Status: ${response.statusCode}\n'
        'Body: ${response.body}',
      );
    }
  }
}
