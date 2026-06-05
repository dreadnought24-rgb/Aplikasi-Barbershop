import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../config/api_config.dart';

class BookingService {
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Kirim data booking baru (POST)
  static Future<BookingResponse> kirimBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/booking/create_booking.php'),
            body: {
              'user_id': userId,
              'pencukur_id': pencukurId,
              'booking_date': bookingDate,
              'booking_time': bookingTime,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookingResponse.fromJson(data);
      } else {
        return BookingResponse(
          success: false,
          message: 'Gagal terhubung ke server (${response.statusCode})',
        );
      }
    } catch (e) {
      return BookingResponse(success: false, message: 'Koneksi error: $e');
    }
  }

  // 2. Ambil booking terbaru milik user (GET)
  static Future<BookingModel?> getBooking(int userId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/booking/get_user_booking.php?user_id=$userId',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return BookingModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 3. Ambil slot waktu yang masih tersedia
  static Future<List<String>> getAvailableSlots({
    required String tanggal,
    required String idPencukur,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/booking/check_slot.php?tanggal=$tanggal&id_pencukur=$idPencukur',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<String>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Ambil semua booking (admin)
  static Future<List<BookingModel>> getAllBookings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/get_all_bookings.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final List data = jsonData['data'];
          return data.map((item) => BookingModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
