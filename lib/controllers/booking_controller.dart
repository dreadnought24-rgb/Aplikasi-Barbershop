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
    // required String jumlahOrang,
  }) async {
    isLoading = true;

    final response = await BookingService.kirimBooking(
      userId: userId,
      pencukurId: pencukurId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      // jumlahOrang: jumlahOrang,
    );

    statusMessage = response.message;
    isLoading = false;

    return response.success;
  }

  Future<List<BookingModel>> getAllBookings() async {
    return BookingService.getAllBookings();
  }
}
