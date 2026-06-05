class BookingModel {
  final String bookingId;
  final String barber;
  final String date;
  final String time;
  final String queue;
  final String status;

  BookingModel({
    required this.bookingId,
    required this.barber,
    required this.date,
    required this.time,
    required this.queue,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
<<<<<<< HEAD
      bookingId: (json['booking_id'] ?? json['id'] ?? '').toString(),
=======

      bookingId: json['booking_id'].toString(),//booking_id?
>>>>>>> 8739a2ba6529c983cfe42196b0fe71bf8d5474d9
      barber: json['nama_pencukur'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      queue: (json['queue_number'] ?? '').toString(),
      status: json['status'] ?? 'belum bayar',
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
