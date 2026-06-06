import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/profile_model.dart';

class ProfileService {
  // ── LOAD: Ambil data dari API, fallback ke SharedPreferences ──
  Future<ProfileModel> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final localUserId = prefs.getInt('user_id') ?? 0;

    if (localUserId == 0) {
      return ProfileModel.fromPrefs({}, 0);
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/get_user.php?user_id=$localUserId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['success'] == true) {
          final model = ProfileModel.fromJson({
            ...resData['data'],
            'user_id': localUserId,
          });

          // Simpan ke SharedPreferences sebagai backup lokal
          await _saveToPrefs(prefs, model);
          return model;
        }
      }
    } catch (_) {
      // Offline / koneksi gagal → gunakan data lokal terakhir
    }

    // Fallback: pakai data SharedPreferences
    return ProfileModel.fromPrefs({
      'username': prefs.getString('username'),
      'nama': prefs.getString('nama'),
      'no_hp': prefs.getString('no_hp'),
    }, localUserId);
  }

  // ── UPDATE: Kirim perubahan field ke database via API POST ──
  //
  // [dbColumn] → nama kolom di tabel MySQL, misal: 'username', 'nama', 'no_hp', 'password'
  // [newValue]  → nilai baru yang akan disimpan
  // Melempar [Exception] jika gagal, agar pemanggil bisa menampilkan pesan error.
  Future<void> updateField({
    required int userId,
    required String dbColumn,
    required String newValue,
  }) async {
    if (newValue.trim().isEmpty) return;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/update_user.php'),
      body: {
        'user_id': userId.toString(),
        'column': dbColumn,
        'value': newValue,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal memperbarui ke database server.');
      }
    } else {
      throw Exception('Koneksi bermasalah (${response.statusCode})');
    }
  }

  // ── FOTO PROFIL: Ambil path gambar dari SharedPreferences ──
  Future<File?> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && imagePath.isNotEmpty) {
      return File(imagePath);
    }
    return null;
  }

  // ── FOTO PROFIL: Simpan path gambar ke SharedPreferences ──
  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  // ── LOGOUT: Hapus semua data sesi dari SharedPreferences ──
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Helper private ──
  Future<void> _saveToPrefs(SharedPreferences prefs, ProfileModel model) async {
    await prefs.setString('username', model.username);
    await prefs.setString('nama', model.nama);
    await prefs.setString('no_hp', model.noHp);
  }
}
