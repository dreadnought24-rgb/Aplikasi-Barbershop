import '../services/auth_service.dart';
import '../utils/session_helper.dart';

class AuthController {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final result = await AuthService.login(username, password);

    if (result.success) {
      await SessionHelper.saveSession(userId: result.userId, role: result.role);
    }

    return {
      'success': result.success,
      'message': result.message,
      'role': result.role,
      'id': result.userId,
    };
  }
}
//aman