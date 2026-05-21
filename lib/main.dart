import 'package:flutter/material.dart';

// Import booking screen
import 'screens/booking_screen.dart';

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

      // Halaman pertama
      home: const BookingScreen(),//thariq
    );
  }//hallo
}