import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../config/routes.dart'; 

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  BookingModel? booking;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    // Membaca status booking untuk ID user 1 (bisa disesuaikan)
    final data = await BookingService.getBooking(1);

    setState(() {
      booking = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Booking"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : booking == null
              ? const Center(
                  child: Text("Booking tidak ditemukan"),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Barber : ${booking!.barber}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tanggal : ${booking!.date}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Jam : ${booking!.time}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Queue : ${booking!.queue}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Status : ${booking!.status}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Kembali ke Home dan menghapus tumpukan screen di belakangnya
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                          child: const Text("Kembali ke Home"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}