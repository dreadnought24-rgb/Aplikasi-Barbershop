// Class untuk menampung data barber
class BarberModel {

  // Variabel id barber
  final String id;

  // Variabel nama barber
  final String nama;

  // Constructor
  BarberModel({
    required this.id,
    required this.nama,
  });

  // Mengubah JSON dari PHP menjadi object Dart
  factory BarberModel.fromJson(Map<String, dynamic> json) {

    return BarberModel(

      // Mengambil id dari JSON
      id: json['id'].toString(),

      // Mengambil nama dari JSON
      nama: json['nama'],
    );
  }
}