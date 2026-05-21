import 'dart:convert';
<<<<<<< HEAD
import 'package:http/http.dart' as http;
// PASTIKAN JALUR IMPORTNYA SEPERTI INI (Membuka folder models)
import 'package:flutter_application_1/models/booking_model.dart';

class BookingService {
  static const String baseUrl = "http://localhost/php_barbershop";

  Future<BookingResponse> kirimBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
    required String jumlahOrang,
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
              'jumlah_orang': jumlahOrang,
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
}
=======

import 'package:http/http.dart' as http;

import '../models/booking_model.dart';

class BookingService {

  static Future<BookingModel?> getBooking(int userId) async {

    final url = Uri.parse(
      "http://10.0.2.2/barbershop_api/booking/get_user_booking.php?user_id=$userId"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {

        return BookingModel.fromJson(
          jsonData['data']
        );

      }

    }

    return null;

  }

}
>>>>>>> 2434601903b35257befa02ca70e9ad39b928e006
