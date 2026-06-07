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
    required String service,    // required String jumlahOrang,
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
              'layanan': service,
              // 'jumlah_orang': jumlahOrang,
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
static Future<List<BookingModel>> getBooking(int userId) async {
  try {
    final url = Uri.parse(
      '$baseUrl/booking/get_user_booking.php?user_id=$userId',
    );

    final response =
        await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        final List<dynamic> data = jsonData['data'];

        return data
            .map((e) => BookingModel.fromJson(e))
            .toList();
      }
    }

    return [];
  } catch (e) {
    return [];
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

  // 5. Update queue setelah booking selesai/cancel
static Future<bool> updateQueue({
  required String bookingId,
  required String pencukurId,
}) async {
  try {
    // Tambah print ini sementara
    print('UPDATEQUEUE bookingId: $bookingId');
    print('UPDATEQUEUE pencukurId: $pencukurId');

    final response = await http
        .post(
          Uri.parse('$baseUrl/admin/update_queue.php'),
          body: {
            'booking_id': bookingId,
            'pencukur_id': pencukurId,
          },
        )
        .timeout(const Duration(seconds: 10));

    // Tambah print response
    print('UPDATEQUEUE response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  } catch (e) {
    print('UPDATEQUEUE ERROR: $e');
    return false;
  }
}

// 6. Cek beban barber setelah booking
static Future<void> checkBarberLoad() async {
  try {
    await http
        .post(Uri.parse('$baseUrl/admin/check_barber_load.php'))
        .timeout(const Duration(seconds: 10));
  } catch (e) {
    // Silent fail - tidak perlu notif ke user
  }
}



}
