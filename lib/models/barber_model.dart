class BarberModel {
  final String id;
  final String nama;

  BarberModel({
    required this.id,
    required this.nama,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      // Mengakomodasi key 'id', 'pencukur_id', atau 'id_pencukur' dan dipaksa menjadi String
      id: (json['id'] ?? json['pencukur_id'] ?? json['id_pencukur'] ?? '').toString(),
      nama: json['nama_pencukur'] ?? json['nama'] ?? 'Tanpa Nama',
    );
  }
}