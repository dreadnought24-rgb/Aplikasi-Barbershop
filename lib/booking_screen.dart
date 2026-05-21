import 'package:flutter/material.dart';

// Import model
import 'barber_model.dart';

// Import service
import 'barber_service.dart';
import 'booking_service.dart';

// Stateful karena datanya berubah
class BookingScreen extends StatefulWidget {

  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {

  // Menyimpan data barber
  List<BarberModel> barberList = [];

  // Menyimpan data slot
  List<String> slotList = [];

  @override
  void initState() {

    super.initState();

    // Saat halaman dibuka
    getBarber();

    // Ambil slot
    getSlot();
  }

  // Function mengambil barber
  Future<void> getBarber() async {

    final data =
        await BarberService.getBarber();

    // Update UI
    setState(() {

      barberList = data;
    });
  }

  // Function mengambil slot
  Future<void> getSlot() async {

    final data =
        await BookingService.getAvailableSlots(
      '2026-05-21',
    );

    // Update UI
    setState(() {

      slotList = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Booking Barbershop',
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // Judul barber
            const Text(

              'Daftar Barber',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Menampilkan barber
            ...barberList.map(

              (barber) => ListTile(

                leading: const Icon(Icons.person),

                title: Text(
                  barber.nama,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Judul slot
            const Text(

              'Slot Tersedia',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Menampilkan slot
            ...slotList.map(

              (slot) => ListTile(

                leading: const Icon(Icons.access_time),

                title: Text(slot),
              ),
            ),
          ],
        ),
      ),
    );
  }
}