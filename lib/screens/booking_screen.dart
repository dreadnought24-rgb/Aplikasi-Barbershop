import 'package:flutter/material.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';
import 'package:flutter_application_1/controllers/booking_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController _controller = BookingController();

  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final jumlahController = TextEditingController();

  List<BarberModel> barberList = [];
  List<String> slotList = [];
  bool isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    getBarber();
    getSlot();
  }

  Future<void> getBarber() async {
    final data = await BarberService.getBarber();
    setState(() {
      barberList = data;
    });
  }

  Future<void> getSlot() async {
    final data = await BookingService.getAvailableSlots();
    setState(() {
      slotList = data;
    });
  }

  Future<void> submitBooking() async {
    setState(() {
      isLoadingSubmit = true;
    });

    // Mengirim data dari inputan form
    bool isSuccess = await _controller.createBooking(
      userId: "1", // Sementara hardcode, nanti bisa ambil dari session login
      pencukurId: "2", // Sementara hardcode, nanti bisa diambil dari pilihan barberList
      bookingDate: dateController.text,
      bookingTime: timeController.text,
      jumlahOrang: jumlahController.text,
    );

    setState(() {
      isLoadingSubmit = false;
    });

    // Menampilkan pesan response dari server PHP menggunakan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_controller.statusMessage)),
    );

    if (isSuccess) {
      // Jika sukses, kamu bisa kosongkan form atau pindah halaman
      dateController.clear();
      timeController.clear();
      jumlahController.clear();
    }
  }

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
      appBar: AppBar(title: const Text('Form Booking Barbershop')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Tanggal (YYYY-MM-DD)",
                hintText: "Contoh: 2026-05-25",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Jam (HH:MM)",
                hintText: "Contoh: 14:00",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Orang",
                hintText: "Contoh: 1",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoadingSubmit ? null : submitBooking,
              child: isLoadingSubmit
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pesan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}