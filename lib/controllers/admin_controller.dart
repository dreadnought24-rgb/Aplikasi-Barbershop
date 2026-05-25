import '../services/admin_service.dart';

class AdminController {

  String statusMessage = "";
  bool isLoading = false;

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {

    isLoading = true;

    bool success =
        await AdminService.updateBookingStatus(
          bookingId: bookingId,
          status: status,
        );

    statusMessage =
        success
            ? "Status berhasil diupdate"
            : "Gagal update status";

    isLoading = false;

    return success;
  }
}