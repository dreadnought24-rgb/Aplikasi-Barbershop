import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/base_background.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final namaController = TextEditingController();
  final usernameController = TextEditingController();
  final noHpController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void register() async {
    final nama = namaController.text.trim();
    final username = usernameController.text.trim();
    final noHp = noHpController.text.trim();
    final password = passwordController.text.trim();

    // Validasi kosong
    if (nama.isEmpty || username.isEmpty || noHp.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi", style: TextStyle(fontFamily: 'InriaSerif')),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService.register(
      username: username,
      password: password,
      nama: nama,
      noHp: noHp,
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    // Jika berhasil
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'], style: const TextStyle(fontFamily: 'InriaSerif')),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'], style: const TextStyle(fontFamily: 'InriaSerif')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    usernameController.dispose();
    noHpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks utama serasi dengan Login
              const Text(
                'Buat Akun',
                style: TextStyle(
                  fontFamily: 'InriaSerif',
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // Input Nama
              TextField(
                controller: namaController,
                style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  labelStyle: TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
                  floatingLabelStyle: TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                  hintText: "Nama lengkap Anda.....",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'InriaSerif'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Input Username
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                decoration: const InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
                  floatingLabelStyle: TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                  hintText: "Buat nama pengguna.....",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'InriaSerif'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Input No HP
              TextField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                decoration: const InputDecoration(
                  labelText: "No HP",
                  labelStyle: TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
                  floatingLabelStyle: TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                  hintText: "08xxxxxxxxxx",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'InriaSerif'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Input Password
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
                  floatingLabelStyle: TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                  hintText: "*******",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'InriaSerif'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => register(),
              ),
              const SizedBox(height: 40),

              // Tombol Register Kotak Hitam
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif'),
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // Tombol Login bawah dengan efek Hover
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(
                        color: Colors.white70, 
                        fontSize: 14, 
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.grey,
                      ).copyWith(
                        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                              return Colors.white; // Berubah warna jadi putih saat kursor di atasnya
                            }
                            return Colors.grey;
                          },
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InriaSerif',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}