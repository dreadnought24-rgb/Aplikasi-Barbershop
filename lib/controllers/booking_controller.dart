import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/booking_service.dart';
import 'package:flutter_application_1/models/booking_model.dart';

class BookingController extends ChangeNotifier {
  final BookingService _service = BookingService();

  bool isLoading = false;
  String statusMessage = "";
  int? nomorAntrean;

  // Nama fungsi diubah menjadi createBooking agar cocok dengan lib/screens/booking_screen.dart kamu
  Future<void> createBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
    required String jumlahOrang,
  }) async {
    isLoading = true;
    statusMessage = "Mengirim booking ke database...";
    nomorAntrean = null;
    notifyListeners();

    // Memanggil service untuk kirim data ke backend PHP
    BookingResponse response = await _service.kirimBooking(
      userId: userId,
      pencukurId: pencukurId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      jumlahOrang: jumlahOrang,
    );

    isLoading = false;

    if (response.success) {
      nomorAntrean = response.queueNumber;
      statusMessage =
          "Sukses! ${response.message}. Nomor Queue Anda: $nomorAntrean";
    } else {
      statusMessage = "Gagal: ${response.message}";
    }

    notifyListeners();
  }
}
