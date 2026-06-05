import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {

  static Future<void> saveSession({
    required int userId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', true);
    await prefs.setInt('user_id', userId);
    await prefs.setString('role', role);
  }

    static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); //  Mengambil data int user_id
  }

  // Menyimpan ID pencukur (Andi/Budi) saat sinkronisasi admin berhasil
  static Future<void> savePencukurId(String pencukurId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pencukur_id', pencukurId);
  }

  // Mengambil ID pencukur untuk filter antrean booking
  static Future<String?> getPencukurId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pencukur_id');
  }

  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Menggunakan .clear() akan otomatis menghapus semua key data session sekaligus
    await prefs.clear();
  }
}