class ProfileModel {
  final int userId;
  final String username;
  final String nama;
  final String noHp;

  const ProfileModel({
    required this.userId,
    required this.username,
    required this.nama,
    required this.noHp,
  });

  /// Buat dari JSON response API
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
    );
  }

  /// Buat dari data SharedPreferences (fallback offline)
  factory ProfileModel.fromPrefs(Map<String, String?> prefs, int userId) {
    return ProfileModel(
      userId: userId,
      username: prefs['username'] ?? 'User',
      nama: prefs['nama'] ?? 'Nama Lengkap',
      noHp: prefs['no_hp'] ?? '-',
    );
  }

  /// Salin dengan field tertentu diubah (immutable update)
  ProfileModel copyWith({
    int? userId,
    String? username,
    String? nama,
    String? noHp,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
    );
  }
}
