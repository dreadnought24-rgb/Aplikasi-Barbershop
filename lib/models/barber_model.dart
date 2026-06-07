class BarberModel {
  final String id;
  final String nama;

  BarberModel({
    required this.id,
    required this.nama,
  });

  
factory BarberModel.fromJson(Map<String, dynamic> json) {
  return BarberModel(
    // Kembalikan ke id (nilai 1,2,3) karena tb_booking.pencukur_id pakai id ini
    id: (json['id'] ?? json['pencukur_id'] ?? json['id_pencukur'] ?? '').toString(),
    nama: json['nama_pencukur'] ?? json['nama'] ?? 'Tanpa Nama',
  );
}
}