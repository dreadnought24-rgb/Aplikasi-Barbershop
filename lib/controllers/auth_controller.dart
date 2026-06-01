import '../services/auth_service.dart';
import '../utils/session_helper.dart';

class AuthController {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final result = await AuthService.login(
      username: username,
      password: password,
    );

    if (result['success'] == true) {
      final dynamic rawUserId = result['user_id'] ?? result['id'];

      await SessionHelper.saveSession(
        userId: rawUserId is int ? rawUserId : int.parse(rawUserId.toString()),
        role: result['role'],
      );
    }

    return result;
  }
}
