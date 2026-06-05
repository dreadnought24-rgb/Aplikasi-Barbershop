import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../config/api_config.dart';

class BookingService {
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Fungsi untuk mengirim data Booking (POST)
  static Future<BookingResponse> kirimBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
    // required String jumlahOrang,
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
              // 'jumlah_orang': jumlahOrang,
            },
          )
          .timeout(const Duration(seconds: 5));

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
      final url = Uri.parse(
        '$baseUrl/booking/get_user_booking.php?user_id=$userId',
      );

      print("GET BOOKING URL: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        print("JSON DATA: $jsonData");

        if (jsonData['success'] == true) {
          return BookingModel.fromJson(jsonData['data']);
        } else {
          print("BOOKING TIDAK DITEMUKAN DARI PHP");
        }
      }

      return null;
    } catch (e) {
      print("ERROR GET BOOKING: $e");

      return null;
    }
  }

  // 3. Fungsi untuk mengambil data slot waktu (GET)
  // Ubah fungsi getAvailableSlots agar menerima parameter tanggal dan id_pencukur
  static Future<List<String>> getAvailableSlots({
    required String tanggal,
    required String idPencukur,
  }) async {
    try {
      // Memanggil check_slot.php sambil mengirim query parameter (?tanggal=...&id_pencukur=...)
      final url = Uri.parse(
        '$baseUrl/booking/check_slot.php?tanggal=$tanggal&id_pencukur=$idPencukur',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Karena check_slot.php langsung mengembalikan Array JSON (contoh: ["09.00", "11.00"])
        // Kita langsung decode sebagai List<String>
        final List<dynamic> jsonData = jsonDecode(response.body);
        return List<String>.from(jsonData);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Ambil semua booking untuk admin
  static Future<List<BookingModel>> getAllBookings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/get_all_bookings.php'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List data = jsonData['data'];

          return data.map((item) => BookingModel.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      print("ERROR GET ALL BOOKINGS: $e");

      return [];
    }
  }
}
