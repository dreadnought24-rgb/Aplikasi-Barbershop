import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barber_model.dart';
import '../config/api_config.dart';

class AdminService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Fungsi Update Status - Menggunakan key 'id' sesuai kolom DB
  static Future<bool> updateBookingStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/update_booking_status.php'),
            body: {'id': id, 'status': status},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (e) {
      print("ERROR UPDATE STATUS: $e");
      return false;
    }
  }

  // Fungsi Get Data Pencukur
  static Future<BarberModel?> getBarberData(int userId) async {
    try {
      var url = Uri.parse('$baseUrl/admin/get_barber_data.php');
      var response = await http.post(url, body: {'user_id': userId.toString()});//user_id?

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          return BarberModel.fromJson(data);
        } else {
          print("Pesan Server: ${data['message']}");
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error AdminService (getBarberData): $e');
      return null;
    }
  }

  // Fungsi Get Antrean khusus Pencukur tertentu
  static Future<List<dynamic>?> getBarberQueue(String pencukurId) async {
    try {
      var url = Uri.parse('$baseUrl/admin/get_barber_queue.php');
      var response = await http.post(url, body: {'pencukur_id': pencukurId});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          print("Pesan Server: ${data['message']}");
          return [];
        }
      }
      return null;
    } catch (e) {
      print('Error AdminService (getBarberQueue): $e');
      return null;
    }
  }
}
