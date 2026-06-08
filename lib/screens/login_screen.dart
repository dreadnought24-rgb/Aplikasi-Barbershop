import 'package:flutter/material.dart';
import 'main_navigation.dart';
import '../services/auth_service.dart';
import '../utils/session_helper.dart';
import 'register_screen.dart';
import 'admin_screen.dart';
import '../widgets/base_background.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username tidak boleh kosong', style: TextStyle(fontFamily: 'InriaSerif')),
        ),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak boleh kosong', style: TextStyle(fontFamily: 'InriaSerif')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await SessionHelper.saveSession(userId: result.userId, role: result.role);

      if (!mounted) return;

      if (result.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminScreen(adminUserId: result.userId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message, style: const TextStyle(fontFamily: 'InriaSerif')), 
          backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
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
              // Logo BARBERIN di atas heading
              Center(
                child: Image.asset(
                  'assets/images/barberinLogo.png',
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 32),

              // Teks utama "Hi, Siap Cukur?" menggunakan InriaSerif
              const Text(
                'Hi,\nSiap Cukur?',
                style: TextStyle(
                  fontFamily: 'InriaSerif',
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // Input Username
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                decoration: const InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
                  floatingLabelStyle: TextStyle(color: Colors.white, fontFamily: 'InriaSerif'),
                  hintText: "Nama Anda.....",
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
              const SizedBox(height: 25),

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
                onSubmitted: (_) => login(),
              ),
              const SizedBox(height: 40),

              // Tombol Login Kotak Hitam
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
                  onPressed: _isLoading ? null : login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif'),
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // Tombol Register bawah dengan efek Hover
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Belum punya akun? ",
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
                              return Colors.white; // Warna saat kursor di atasnya (hover)
                            }
                            return Colors.grey; // Warna default
                          },
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Register",
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

