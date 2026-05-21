// Untuk JSON
import 'dart:convert';

// Package HTTP
import 'package:http/http.dart' as http;

class BookingService {

  // Function mengambil slot tersedia
  static Future<List<String>> getAvailableSlots(
    String tanggal,
  ) async {

    // Request ke PHP
    final response = await http.get(

      Uri.parse(
        'http://10.0.2.2/barbershop/booking.php?tanggal=$tanggal',
      ),
    );

    // Jika berhasil
    if (response.statusCode == 200) {

      // Decode JSON
      List data = jsonDecode(response.body);

      // Mengubah menjadi List String
      return data
          .map((e) => e.toString())
          .toList();

    } else {

      // Jika gagal
      throw Exception(
        'Gagal mengambil slot',
      );
    }
  }
}