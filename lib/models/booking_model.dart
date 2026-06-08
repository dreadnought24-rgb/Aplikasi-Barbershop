class BookingModel {
  final String bookingId;
  final String pencukurId; // ← TAMBAH
  final String barber;
  final String date;
  final String time;
  final String queue;
  final String status;
  final String? layanan;

  BookingModel({
    required this.bookingId,
    required this.pencukurId, // ← TAMBAH
    required this.barber,
    required this.date,
    required this.time,
    required this.queue,
    required this.status,
    required this.layanan,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: (json['booking_id'] ?? json['id'] ?? '').toString(),
      pencukurId: (json['pencukur_id'] ?? '').toString(), // ← TAMBAH
      barber: json['nama_pencukur'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      queue: (json['queue_number'] ?? '').toString(),
      status: json['status'] ?? 'belum bayar',
      layanan: json['layanan'] ?? json['service'] ?? '',
    );
  }
}

class BookingResponse {
  final bool success;
  final int? queueNumber;
  final String message;

  BookingResponse({
    required this.success,
    this.queueNumber,
    required this.message,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] == true,
      queueNumber: json['queue_number'] != null
          ? int.tryParse(json['queue_number'].toString())
          : null,
      message: json['message'] ?? '',
    );
  }
}
