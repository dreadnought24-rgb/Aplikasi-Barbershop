// Untuk mengubah JSON
import 'dart:convert';

// Package HTTP
import 'package:http/http.dart' as http;

// Import model barber
import '../models/barber_model.dart';

class BarberService {

  // Function mengambil data barber
  static Future<List<BarberModel>> getBarber() async {

    // Request ke PHP
    final response = await http.get(

      Uri.parse(
        'http://10.0.2.2/barbershop/barber.php',
      ),
    );

    // Jika request berhasil
    if (response.statusCode == 200) {

      // Decode JSON menjadi List
      List data = jsonDecode(response.body);

      // Mengubah List JSON menjadi List BarberModel
      return data
          .map((e) => BarberModel.fromJson(e))
          .toList();

    } else {

      // Jika gagal
      throw Exception(
        'Gagal mengambil data barber',
      );
    }
  }
}