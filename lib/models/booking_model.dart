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
      success: json['success'] ?? false,
      queueNumber: json['queue_number'],
      message: json['message'] ?? '',
    );
  }
}
