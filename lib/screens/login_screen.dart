import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/screens/admin_screen.dart';
import 'package:flutter_application_1/screens/main_navigation.dart';
import 'package:flutter_application_1/utils/session_helper.dart';
import 'register_screen.dart';
// import 'home_screen.dart';
import '../controllers/auth_controller.dart';
=======
import '../services/auth_service.dart';
import '../utils/session_helper.dart';
import 'register_screen.dart';
import 'booking_screen.dart';
import 'admin_screen.dart';
>>>>>>> 8841cce94a414010b7ec71460928f803fea0e64b

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

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password tidak boleh kosong'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      // Simpan session ke SharedPreferences sebelum navigate
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
          MaterialPageRoute(builder: (_) => const BookingScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => login(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Login"),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Belum punya akun? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
