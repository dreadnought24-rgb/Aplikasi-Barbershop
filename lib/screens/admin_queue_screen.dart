import 'package:flutter/material.dart';

import '../controllers/admin_controller.dart';
import '../controllers/booking_controller.dart';

import '../models/booking_model.dart';

class AdminQueueScreen extends StatefulWidget {
  const AdminQueueScreen({super.key});

  @override
  State<AdminQueueScreen> createState() =>
      _AdminQueueScreenState();
}

class _AdminQueueScreenState
    extends State<AdminQueueScreen> {

  final BookingController bookingController =
      BookingController();

  final AdminController adminController =
      AdminController();

  List<BookingModel> bookingList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchBookings();
  }

  Future<void> fetchBookings() async {

    setState(() {
      isLoading = true;
    });

    bookingList =
        await bookingController.getAllBookings();

    // FILTER queue belum bayar
    bookingList = bookingList.where(
      (item) => item.status == "belum_bayar",
    ).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateStatus({
    required String bookingId,
    required String status,
  }) async {

    bool success =
        await adminController.updateBookingStatus(
          bookingId: bookingId,
          status: status,
        );

    if(success){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Status berhasil diubah menjadi $status",
          ),
        ),
      );

      // RELOAD QUEUE
      fetchBookings();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal update status"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Queue"),
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : ListView.builder(

              itemCount: bookingList.length,

              itemBuilder: (context, index) {

                final booking = bookingList[index];

                return Card(

                  child: ListTile(

                    title: Text(
                      "Queue ${booking.queue}",
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Barber: ${booking.barber}",
                        ),

                        Text(
                          "${booking.date} | ${booking.time}",
                        ),

                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        ElevatedButton(
                          onPressed: () {

                            updateStatus(
                              bookingId:
                                  booking.bookingId,

                              status: "bayar",
                            );
                          },
                          child: const Text("Bayar"),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: () {

                            updateStatus(
                              bookingId:
                                  booking.bookingId,

                              status: "cancel",
                            );
                          },
                          child: const Text("Cancel"),
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