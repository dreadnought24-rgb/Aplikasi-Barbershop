import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ), // Menampilkan AppBar dengan judul "Home"
      body: const Center(
        child: Text(
          "Login Berhasil", // Menampilkan pesan "Login Berhasil" di tengah layar
        ),
        
      ),
    );
  }
}
