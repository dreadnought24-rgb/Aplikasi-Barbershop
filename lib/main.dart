import 'package:flutter/material.dart';
import 'screens/booking_screen.dart';
import 'config/routes.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Halaman pertama saat aplikasi baru dibuka
      home: const BookingScreen(), 
      
      // Integrasi map rute navigasi aplikasi
      routes: AppRoutes.getRoutes(),
    );
  } 
}