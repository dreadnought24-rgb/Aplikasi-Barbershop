import 'dart:convert';

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