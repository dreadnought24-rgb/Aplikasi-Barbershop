import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/booking_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Inisialisasi Controller
  final BookingController _controller = BookingController();

  // Controller untuk menangkap inputan text di layar
  final dateController = TextEditingController(text: "2026-05-20");
  final timeController = TextEditingController(text: "13:00");
  final jumlahController = TextEditingController(text: "1");

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Barbershop")),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Form Simulasi Antrean (Queue)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Booking (YYYY-MM-DD)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: "Jam Booking (HH:MM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Jumlah Orang",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _controller.isLoading
                      ? null
                      : () {
                          // Memanggil fungsi dengan parameter yang COCOK dengan database & controller
                          _controller
                              .createBooking(
                                userId: "1", // Sementara Dummy ID User
                                pencukurId: "2", // Sementara Dummy ID Kapster
                                bookingDate: dateController.text,
                                bookingTime: timeController.text,
                                jumlahOrang: jumlahController.text,
                              )
                              .then((_) {
                                // Munculkan notifikasi hasil respon dari PHP
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_controller.statusMessage),
                                  ),
                                );
                              });
                        },
                  child: _controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Kirim Booking (Ambil Antrean)",
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 30),
                Divider(thickness: 2, color: Colors.grey[300]),
                const SizedBox(height: 10),

                // Tampilan Log Status Pengujian
                Text(
                  "Log Status Database:\n${_controller.statusMessage}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
