class BarberModel {
  final String id;
  final String nama;

  BarberModel({
    required this.id,
    required this.nama,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      // PASTIKAN key di dalam json['...'] ini sama persis dengan nama kolom di database!
      id: (json['id'] ?? json['id_pencukur'] ?? '').toString(),
      nama: json['nama_pencukur'] ?? json['nama'] ?? 'Tanpa Nama',
    );
  }
}