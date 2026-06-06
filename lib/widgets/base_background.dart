import 'package:flutter/material.dart';

class BaseBackground extends StatelessWidget {
  final Widget child; // Ini untuk menampung isi UI dari halaman lain

  const BaseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Jika halaman memiliki AppBar, kamu bisa menambahkannya di sini, 
      // atau biarkan di halaman masing-masing.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.22, 0.49, 0.69, 1.0],
            colors: [
              Color(0xFF111111),
              Color(0xFF202020),
              Color(0xFF3C3C3C),
              Color(0xFF202020),
              Color(0xFF111111),
            ],
          ),
        ),
        child: child, // Isi UI halaman lain akan muncul di sini
      ),
    );
  }
}