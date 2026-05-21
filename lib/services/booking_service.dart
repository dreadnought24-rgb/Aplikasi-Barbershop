import 'dart:convert';
import 'package:http/http.dart' as http;
// Sesuaikan jalur import ini dengan struktur proyekmu
import 'package:flutter_application_1/models/booking_model.dart';

class BookingService {
  // Gunakan 10.0.2.2 jika kamu menguji menggunakan Emulator Android asli
  // Gunakan localhost jika menggunakan simulator iOS atau Web
  static const String baseUrl = "http://10.0.2.2/php_barbershop";

  // 1. Fungsi untuk mengirim data Booking (POST)
  Future<BookingResponse> kirimBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
    required String jumlahOrang,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/booking/create_booking.php'),
        body: {
          'user_id': userId,
          'pencukur_id': pencukurId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          'jumlah_orang': jumlahOrang,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return BookingResponse.fromJson(decodedData);
      } else {
        return BookingResponse(
          success: false,
          message: "Gagal terhubung ke server (${response.statusCode})",
        );
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: "Koneksi error/Server PHP belum aktif.",
      );
    }
  }

  // 2. Fungsi untuk mengambil data Booking (GET)
  static Future<BookingModel?> getBooking(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/booking/get_user_booking.php?user_id=$userId');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return BookingModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      // Mengembalikan null jika terjadi error koneksi
      return null;
    }
  }
}