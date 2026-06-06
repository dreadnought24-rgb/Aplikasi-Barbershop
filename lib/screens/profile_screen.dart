import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/base_background.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  final _picker = ImagePicker();

  ProfileModel? _profile;
  File? _imageFile;
  bool _isLoading = true;
  bool _isHovered = false;

  // Teks statis untuk field password — tidak pernah ditampilkan dari API
  static const String _passwordMask = '••••••••••••';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ── LOAD ──────────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.loadUserData(),
        _service.loadProfileImage(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as ProfileModel;
        _imageFile = results[1] as File?;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── FOTO PROFIL ───────────────────────────────────────────────────────────

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Ganti Foto Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InriaSerif',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white70),
              title: const Text('Pilih dari Library / Storage',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.white70),
              title: const Text('Ambil Foto dari Kamera',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (picked == null) return;

      await _service.saveProfileImagePath(picked.path);

      if (!mounted) return;
      setState(() => _imageFile = File(picked.path));
      _showSnackBar('Foto profil berhasil diperbarui!');
    } catch (e) {
      _showSnackBar('Gagal mengambil gambar: $e');
    }
  }

  // ── EDIT DIALOG & UPDATE ──────────────────────────────────────────────────

  void _showEditDialog(
    String title,
    String currentVal,
    String dbColumn, {
    bool isPassword = false,
  }) {
    final controller =
        TextEditingController(text: isPassword ? '' : currentVal);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah $title',
          style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
        ),
        content: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan $title baru',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitUpdate(dbColumn, controller.text);
            },
            child: const Text('Simpan',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUpdate(String dbColumn, String newValue) async {
    if (_profile == null || newValue.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _service.updateField(
        userId: _profile!.userId,
        dbColumn: dbColumn,
        newValue: newValue,
      );
      _showSnackBar('Berhasil memperbarui $dbColumn!');
      await _loadAll(); // sinkronisasi ulang dari server
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memperbarui: $e');
    }
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildAvatar(),
                      const SizedBox(height: 16),
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildProfileCard(),
                      const SizedBox(height: 32),
                      _buildLogoutButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = (_profile?.nama.isNotEmpty == true &&
            _profile?.nama != 'Loading...')
        ? _profile!.nama[0].toUpperCase()
        : '?';

    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) {
          setState(() => _isHovered = false);
          _showPickerOptions();
        },
        onTapCancel: () => setState(() => _isHovered = false),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(60, 255, 255, 255), width: 2),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFFD9D9D9),
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Text(initial,
                        style: const TextStyle(
                          fontSize: 40,
                          color: Color(0xFF1E1E1E),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InriaSerif',
                        ))
                    : null,
              ),
            ),
            if (_isHovered)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Icon(Icons.photo_camera,
                    color: Colors.white, size: 30),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Text(
          _profile?.username ?? '',
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Hi, ${_profile?.nama ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'InriaSerif'),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final p = _profile;
    if (p == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildProfileItem(
            label: 'Username',
            value: p.username,
            onEditTap: () =>
                _showEditDialog('Username', p.username, 'username'),
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildProfileItem(
            label: 'Nama',
            value: p.nama,
            onEditTap: () => _showEditDialog('Nama', p.nama, 'nama'),
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildProfileItem(
            label: 'Phone Number',
            value: p.noHp,
            onEditTap: () =>
                _showEditDialog('Phone Number', p.noHp, 'no_hp'),
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildProfileItem(
            label: 'Password',
            value: _passwordMask,
            onEditTap: () =>
                _showEditDialog('Password', '', 'password', isPassword: true),
          ),
        ],
      ),
    );
  }

  // ── LOGOUT ───────────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'InriaSerif',
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white, fontFamily: 'InriaSerif')),
        content: const Text('Yakin ingin keluar dari akun ini?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.logout();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required String label,
    required String value,
    required VoidCallback onEditTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InriaSerif')),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          onPressed: onEditTap,
          icon: const Icon(Icons.edit_note, color: Colors.white70, size: 26),
          splashRadius: 22,
        ),
      ],
    );
  }
}
