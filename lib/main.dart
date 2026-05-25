import 'package:flutter/material.dart';
import 'config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Menggunakan initialRoute untuk menentukan halaman pertama (Login)
      initialRoute: AppRoutes.splash, // Ganti dengan AppRoutes.login jika ingin langsung ke Login
      routes: AppRoutes.getRoutes(),
    );
  }
}

