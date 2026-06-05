import 'package:flutter/material.dart';
import '../config/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selamat Datang di Barbershop",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                // Navigasi dari Home ke Booking
                // Kita juga bisa melempar ID Barber yang dipilih user secara dinamis (Contoh: ID "1")
                Navigator.pushNamed(context, AppRoutes.booking, arguments: "1"); //perlu dicurigai
              },
              child: const Text(
                "Pesan Barbershop Sekarang",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            // OutlinedButton(
            //   style: OutlinedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 40,
            //       vertical: 15,
            //     ),
            //   ),
            //   onPressed: () {
            //     Navigator.pushNamed(context, AppRoutes.admin);
            //   },
            //   child: const Text(
            //     "Masuk ke Admin Screen",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
