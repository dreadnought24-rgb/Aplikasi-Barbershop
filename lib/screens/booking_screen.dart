// =========================
// IMPORT
// =========================
import 'package:flutter/material.dart';

import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';

import 'package:flutter_application_1/controllers/booking_controller.dart';

// =========================
// BOOKING SCREEN
// FOKUS KE ALUR DATA
// =========================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {

  // =========================
  // CONTROLLER BOOKING
  // MENGATUR PROSES BOOKING
  // =========================
  final BookingController _controller =
      BookingController();

  // =========================
  // INPUT DATA USER
  // =========================
  final dateController =
      TextEditingController();

  final timeController =
      TextEditingController();

  final jumlahController =
      TextEditingController();

  // =========================
  // MENYIMPAN DATA BARBER
  // DARI DATABASE / API
  // =========================
  List<BarberModel> barberList = [];

  // =========================
  // MENYIMPAN SLOT TERSEDIA
  // DARI DATABASE / API
  // =========================
  List<String> slotList = [];

  // =========================
  // DIJALANKAN SAAT HALAMAN
  // PERTAMA DIBUKA
  // =========================
  @override
  void initState() {
    super.initState();

    // Ambil data barber
    getBarber();

    // Ambil slot booking
    getSlot();
  }

  // =========================
  // FUNCTION AMBIL BARBER
  // DARI SERVICE
  // =========================
  Future<void> getBarber() async {

    // Request data barber
    final data =
        await BarberService.getBarber();

    // Simpan ke list
    setState(() {
      barberList = data;
    });
  }

  // =========================
  // FUNCTION AMBIL SLOT
  // DARI SERVICE
  // =========================
  Future<void> getSlot() async {

    // Request slot tersedia
    final data =
        await BookingService
            .getAvailableSlots(
      '2026-05-21',
    );

    // Simpan ke list
    setState(() {
      slotList = data;
    });
  }

  // =========================
  // FUNCTION CREATE BOOKING
  // MENGIRIM DATA KE API
  // =========================
  Future<void> submitBooking() async {

    await _controller.createBooking(

      // ID USER
      userId: "1",

      // ID BARBER / PENCUKUR
      pencukurId: "2",

      // TANGGAL BOOKING
      bookingDate:
          dateController.text,

      // JAM BOOKING
      bookingTime:
          timeController.text,

      // JUMLAH ORANG
      jumlahOrang:
          jumlahController.text,
    );

    // =========================
    // HASIL RESPONSE
    // DARI DATABASE / API
    // =========================
    print(
      _controller.statusMessage,
    );
  }

  // =========================
  // HAPUS CONTROLLER
  // AGAR TIDAK MEMORY LEAK
  // =========================
  @override
  void dispose() {

    dateController.dispose();
    timeController.dispose();
    jumlahController.dispose();

    super.dispose();
  }

  // =========================
  // UI SEMENTARA
  // =========================
  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: Text(
          'Fokus Alur Data',
        ),
      ),
    );
  }
}