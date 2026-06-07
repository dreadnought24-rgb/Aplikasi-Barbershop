import '../services/booking_service.dart';
import '../models/booking_model.dart';

class BookingController {
  String statusMessage = '';
  bool isLoading = false;

  Future<bool> createBooking({
    required String userId,
    required String pencukurId,
    required String bookingDate,
    required String bookingTime,
    required String service, // Menerima 'Classic Cut', 'Junior Cut', atau 'Executive Cut'
  }) async {
    isLoading = true;

    // LANGSUNG KIRIM: Tidak perlu dikonversi lagi karena enum database sudah sama persis
    final response = await BookingService.kirimBooking(
      userId: userId,
      pencukurId: pencukurId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      service: service, // Kirim nama layanan langsung tanpa konversi
    );

    statusMessage = response.message;
    isLoading = false;

    return response.success;
  }

  Future<List<BookingModel>> getAllBookings() async {
    return BookingService.getAllBookings();
  }
}