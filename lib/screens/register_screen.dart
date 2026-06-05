import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

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
    // validasi kosong
    if (namaController.text.isEmpty ||
        usernameController.text.isEmpty ||
        noHpController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));

      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService.register(
      username: usernameController.text,
      password: passwordController.text,
      nama: namaController.text,
      noHp: noHpController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    // jika berhasil
    if (result['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "No HP"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Register"),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },

                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
