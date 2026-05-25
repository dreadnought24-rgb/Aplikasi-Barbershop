import 'package:flutter/material.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';
import '../config/routes.dart';
import '../controllers/booking_controller.dart';
import '../controllers/admin_controller.dart';

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

  // Variabel baru untuk menampung Barber ID yang dipilih user
  String? selectedBarberId;

  @override
  void initState() {
    super.initState();
    getBarber();
  }

  Future<void> getBarber() async {
    try {
      final data = await BarberService.getBarber();
      setState(() {
        barberList = data;
        // Set default pilihan barber ke yang pertama jika data tersedia
        if (barberList.isNotEmpty) {
          selectedBarberId = barberList.first.id;
        }
      });
      // Panggil slot pertama kali setelah barber didapatkan
      getSlot();
    } catch (e) {
      debugPrint("Gagal mengambil barber: $e");
    }
  }

  Future<void> getSlot() async {
    // Validasi: Hanya panggil API jika tanggal sudah diisi dan barber sudah dipilih
    if (dateController.text.isEmpty || selectedBarberId == null) {
      return;
    }

    final data = await BookingService.getAvailableSlots(
      tanggal: dateController.text, // Sekarang Dinamis dari inputan user
      idPencukur: selectedBarberId!, // Sekarang Dinamis dari dropdown pencukur
    );

    setState(() {
      slotList = data;
    });
  }

  Future<void> submitBooking() async {
    if (selectedBarberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih barber terlebih dahulu!")),
      );
      return;
    }

    setState(() {
      isLoadingSubmit = true;
    });

    // Mengirim data dinamis ke PHP
    bool isSuccess = await _controller.createBooking(
      userId: "1", // Sementara hardcode ID User login
      pencukurId: selectedBarberId!, // Dinamis
      bookingDate: dateController.text, // Dinamis
      bookingTime: timeController.text, // Dinamis
      jumlahOrang: jumlahController.text, // Dinamis
    );

    setState(() {
      isLoadingSubmit = false;
    });

    // Menampilkan pesan response dari server PHP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.statusMessage),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );

    if (isSuccess) {
      dateController.clear();
      timeController.clear();
      jumlahController.clear();
      // Mengikuti Alur Tugas 4: Pindah ke status dan tutup form booking (pushReplacementNamed)
      Navigator.pushReplacementNamed(context, AppRoutes.status);
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
            // 1. DROPDOWN PILIH BARBER (TUGAS 1)
            const Text("Pilih Barber:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedBarberId,
              items: barberList.map((barber) {
                return DropdownMenuItem<String>(
                  value: barber.id,
                  child: Text(barber.nama),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBarberId = value;
                });
                getSlot(); // Refresh slot kosong saat ganti barber
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // 2. INPUT TANGGAL
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Tanggal (YYYY-MM-DD)",
                hintText: "Contoh: 2026-05-25",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Trigger otomatis mencari slot jika user selesai mengetik tanggal dengan benar (10 karakter)
                if (value.length == 10) {
                  getSlot();
                }
              },
            ),
            const SizedBox(height: 16),

            // 3. TAMPILAN SLOT YANG TERSEDIA (INFORMASI DARI TUGAS 1 & TUGAS 2)
            if (slotList.isNotEmpty) ...[
              const Text("Slot Tersedia Hari Ini:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: slotList.map((slot) {
                  return ChoiceChip(
                    label: Text(slot),
                    selected: timeController.text == slot,
                    onSelected: (selected) {
                      setState(() {
                        timeController.text = selected ? slot : "";
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // 4. INPUT JAM MANUAL (Jika tidak memilih dari Chip diatas)
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Jam (HH:MM)",
                hintText: "Contoh: 10.00",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 5. INPUT JUMLAH ORANG
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Orang",
                hintText: "Contoh: 1",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 6. TOMBOL SUBMIT (TUGAS 2 & 4)
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: isLoadingSubmit ? null : submitBooking,
              child: isLoadingSubmit
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Pesan Sekarang', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}