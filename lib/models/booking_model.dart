class BookingModel {

  final String barber;
  final String date;
  final String time;
  final String queue;
  final String status;

  BookingModel({
    required this.barber,
    required this.date,
    required this.time,
    required this.queue,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {

    return BookingModel(

      barber: json['nama_pencukur'] ?? '',

      date: json['booking_date'] ?? '',

      time: json['booking_time'] ?? '',

      queue: json['queue_number'].toString(),

      status: json['status'] ?? '',

    );

  }

}