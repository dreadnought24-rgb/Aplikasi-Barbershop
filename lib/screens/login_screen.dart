import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin_screen.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
    });

    final result = await AuthService.login(
      username: usernameController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {

  String role = result['role'];

  if (role == 'admin') {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminScreen(),//belum dibuat tampilan
      ),
    );

  } else {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );

  }

} else {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result['message'])),
  );

}
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
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
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
