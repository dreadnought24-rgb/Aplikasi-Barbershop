import 'package:flutter/material.dart';
import '../config/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Berpindah ke form booking menggunakan Named Route terdaftar
            Navigator.pushNamed(context, AppRoutes.booking);
          },
          child: const Text('Booking Sekarang'),
        ),
      ),
    );
  }
}