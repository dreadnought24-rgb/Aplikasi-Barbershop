import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {

  static const String baseUrl =
      "http://192.168.1.6/barbershop_api";

  static Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {

    try {

      final response = await http.post(

        Uri.parse(
          '$baseUrl/admin/update_booking_status.php',
        ),

        body: {
          'booking_id': bookingId,
          'status': status,
        },

      ).timeout(const Duration(seconds: 5));

      if(response.statusCode == 200){

        final jsonData = jsonDecode(response.body);

        return jsonData['success'] == true;
      }

      return false;

    } catch (e) {

      print("ERROR UPDATE STATUS: $e");

      return false;
    }
  }
}