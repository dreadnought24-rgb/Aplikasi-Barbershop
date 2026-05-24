import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barber_model.dart';

class BarberService {

  static const String baseUrl =
      "http://192.168.1.6/barbershop_api";

  static Future<List<BarberModel>> getBarber() async {

    final url =
        Uri.parse('$baseUrl/barber/get_barbers.php');

    print("URL: $url");

    final response = await http.get(url);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data
          .map((e) => BarberModel.fromJson(e))
          .toList();

    } else {

      throw Exception(
        'Gagal mengambil data barber\n'
        'Status: ${response.statusCode}\n'
        'Body: ${response.body}',
      );
    }
  }
}