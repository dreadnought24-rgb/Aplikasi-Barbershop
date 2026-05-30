import '../models/barber_model.dart';
import '../services/admin_service.dart';
import '../utils/session_helper.dart';

class AdminController {
  BarberModel? currentBarber;
  List<dynamic> queueList = [];
  
  String statusMessage = "";
  bool isLoading = false;

  // 1. Inisialisasi Sesi Admin (Koneksi User login ke Data Pencukur)
  Future<bool> initAdminSession(int loggedInUserId) async {
    isLoading = true;
    try {
      currentBarber = await AdminService.getBarberData(loggedInUserId);

      if (currentBarber != null) {
        await SessionHelper.savePencukurId(currentBarber!.id);
        print("Sinkronisasi Berhasil. Pencukur Aktif: ${currentBarber!.nama}");
        return true;
      } else {
        print("User ini tidak terikat dengan data pencukur.");
        return false;
      }
    } catch (e) {
      print("Error initAdminSession: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }

  // 2. Mengambil List Antrean Khusus Pencukur yang sedang aktif
  Future<void> fetchMyQueue() async {
    isLoading = true;
    try {
      String? pencukurId = await SessionHelper.getPencukurId();
      
      if (pencukurId != null && pencukurId.isNotEmpty) {
        var res = await AdminService.getBarberQueue(pencukurId);
        if (res != null) {
          queueList = res;
        }
      } else {
        print("Gagal memuat antrean karena pencukur_id kosong.");
      }
    } catch (e) {
      print("Error fetchMyQueue: $e");
    } finally {
      isLoading = false;
    }
  }

  // 3. Mengubah Status Antrean Booking (Menerima parameter id)
  Future<bool> updateBookingStatus({
    required String id,
    required String status,
  }) async {
    isLoading = true;

    bool success = await AdminService.updateBookingStatus(
      id: id,
      status: status,
    );

    statusMessage = success ? "Status berhasil diupdate" : "Gagal update status";

    isLoading = false;

    return success;
  }
}
