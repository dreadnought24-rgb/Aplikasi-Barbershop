// Untuk mengubah JSON
import 'dart:convert';

// Package HTTP
import 'package:http/http.dart' as http;

// Import model barber
import '../models/barber_model.dart';

class BarberService {

  // Function mengambil data barber
  static Future<List<BarberModel>> getBarber() async {

    // URL sudah disesuaikan ke sub-folder barber/get_barbers.php
    final response = await http.get(

      Uri.parse(
<<<<<<< HEAD
        'http://localhost/php_barbershop/barber/get_barbers.php',
=======
        'http://192.168.1.15/barbershop/barber.php',
>>>>>>> 733c0e1947b42dfd133df0034f5f3b50d48af4fb
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