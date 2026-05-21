import 'package:flutter/material.dart';

// =========================
// IMPORT MODEL & SERVICE
// =========================
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';

// =========================
// IMPORT CONTROLLER
// =========================
import 'package:flutter_application_1/controllers/booking_controller.dart';

// =========================
// HALAMAN BOOKING
// =========================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  // =========================
  // CONTROLLER BOOKING
  // =========================
  final BookingController _controller =
      BookingController();

  // =========================
  // TEXTFIELD CONTROLLER
  // =========================
  final dateController =
      TextEditingController(
    text: "2026-05-20",
  );

  final timeController =
      TextEditingController(
    text: "13:00",
  );

  final jumlahController =
      TextEditingController(
    text: "1",
  );

  // =========================
  // LIST DATA BARBER
  // =========================
  List<BarberModel> barberList = [];

  // =========================
  // LIST SLOT TERSEDIA
  // =========================
  List<String> slotList = [];

  // =========================
  // INIT STATE
  // DIPANGGIL SAAT HALAMAN
  // PERTAMA DIBUKA
  // =========================
  @override
  void initState() {
    super.initState();

    getBarber();
    getSlot();
  }

  // =========================
  // AMBIL DATA BARBER
  // =========================
  Future<void> getBarber() async {

    final data =
        await BarberService.getBarber();

    setState(() {
      barberList = data;
    });
  }

  // =========================
  // AMBIL SLOT TERSEDIA
  // =========================
  Future<void> getSlot() async {

    final data =
        await BookingService
            .getAvailableSlots(
      '2026-05-21',
    );

    setState(() {
      slotList = data;
    });
  }

  // =========================
  // DISPOSE CONTROLLER
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
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Booking Barbershop",
        ),
      ),

      body: AnimatedBuilder(

        animation: _controller,

        builder: (context, _) {

          return Padding(

            padding:
                const EdgeInsets.all(20),

            child: SingleChildScrollView(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [

                  // =========================
                  // JUDUL
                  // =========================
                  const Text(

                    "Form Simulasi Antrean",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // INPUT TANGGAL
                  // =========================
                  TextField(

                    controller:
                        dateController,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Tanggal Booking",

                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // INPUT JAM
                  // =========================
                  TextField(

                    controller:
                        timeController,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Jam Booking",

                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // INPUT JUMLAH ORANG
                  // =========================
                  TextField(

                    controller:
                        jumlahController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Jumlah Orang",

                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // BUTTON BOOKING
                  // =========================
                  ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 15,
                      ),
                    ),

                    onPressed:
                        _controller.isLoading
                            ? null
                            : () {

                                _controller
                                    .createBooking(

                                  userId: "1",

                                  pencukurId: "2",

                                  bookingDate:
                                      dateController
                                          .text,

                                  bookingTime:
                                      timeController
                                          .text,

                                  jumlahOrang:
                                      jumlahController
                                          .text,
                                )

                                    .then((_) {

                                  ScaffoldMessenger
                                          .of(context)
                                      .showSnackBar(

                                    SnackBar(

                                      content: Text(
                                        _controller
                                            .statusMessage,
                                      ),
                                    ),
                                  );
                                });
                              },

                    child:
                        _controller.isLoading

                            ? const SizedBox(

                                height: 20,
                                width: 20,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(

                                "Kirim Booking",

                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // LIST BARBER
                  // =========================
                  const Text(

                    "Daftar Barber",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...barberList.map(

                    (barber) => ListTile(

                      leading:
                          const Icon(Icons.person),

                      title:
                          Text(barber.nama),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // SLOT TERSEDIA
                  // =========================
                  const Text(

                    "Slot Tersedia",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...slotList.map(

                    (slot) => ListTile(

                      leading: const Icon(
                        Icons.access_time,
                      ),

                      title: Text(slot),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // STATUS DATABASE
                  // =========================
                  Divider(
                    thickness: 2,
                    color: Colors.grey[300],
                  ),

                  const SizedBox(height: 10),

                  Text(

                    "Log Status:\n${_controller.statusMessage}",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      fontSize: 14,

                      fontStyle:
                          FontStyle.italic,

                      color:
                          Colors.blueGrey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}