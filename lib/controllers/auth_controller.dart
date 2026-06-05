import '../services/auth_service.dart';
import '../utils/session_helper.dart';

class AuthController {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Tambahkan print untuk melacak di Debug Console
      print("INFO: Memulai proses AuthService.login...");
      
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      print("INFO: AuthService memberikan respon: $result");

      if (result['success'] == true) {
        final dynamic rawUserId = result['user_id'] ?? result['id'];

        await SessionHelper.saveSession(
          userId: rawUserId is int ? rawUserId : int.parse(rawUserId.toString()),
          role: result['role'],
        );
      }

      return result;
    } catch (e) {
      // Jika terjadi crash atau error di tengah jalan, tangkap di sini
      print("ERROR di AuthController: $e");
      return {
        'success': false,
        'message': 'Terjadi kesalahan internal sistem: $e'
      };
    }
  }
}
