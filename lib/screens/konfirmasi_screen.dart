import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/booking_service.dart';
import '../config/routes.dart';
import '../controllers/booking_controller.dart';
import '../widgets/base_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../services/notification_service.dart';

class KonfirmasiScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const KonfirmasiScreen({super.key, required this.data});

  @override
  State<KonfirmasiScreen> createState() => _KonfirmasiScreenState();
}

class _KonfirmasiScreenState extends State<KonfirmasiScreen> {
  final BookingController _controller = BookingController();
  bool isLoadingSubmit = false;

  Future<void> _submit() async {
  setState(() => isLoadingSubmit = true);

  final isEditMode = widget.data['mode'] == 'edit';
      print('MODE: $isEditMode');
    print('DATA: ${widget.data}');

  if (isEditMode) {
    // Mode edit → panggil updateBookingSchedule
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    final response = await BookingService.updateBookingSchedule(
      bookingId: widget.data['bookingId'],
      userId: userId.toString(),
      bookingDate: widget.data['date'],
      bookingTime: widget.data['time'],
    );

    if (!mounted) return;
    setState(() => isLoadingSubmit = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: response.success ? Colors.green : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );

   if (response.success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(response.message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
  
  // Kembali ke main navigation dan refresh
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.mainNav,
    (route) => false,
  );
}

  } else {
    // Mode baru → seperti sebelumnya
    final isSuccess = await _controller.createBooking(
      userId: widget.data['userId'],
      pencukurId: widget.data['barberId'],
      bookingDate: widget.data['date'],
      bookingTime: widget.data['time'],
      service: widget.data['service'],
    );

    if (!mounted) return;
    setState(() => isLoadingSubmit = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.statusMessage),
        backgroundColor: isSuccess ? Colors.green : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (isSuccess) {
      await BookingService.checkBarberLoad();
      Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
    }
  }

  
}


  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final int price = data['price'];
    final String formattedPrice =
        'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.data['mode'] == 'edit' ? 'Ubah Jadwal' : 'Konfirmasi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'InriaSerif',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontFamily: 'InriaSerif',
                ),
              ),
              const SizedBox(height: 16),

              // ── CARD RINGKASAN ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRow(Icons.content_cut, 'Layanan', data['service']),
                    const Divider(color: Colors.white12, height: 28),
                    _buildRow(
                      Icons.person_outline,
                      'Barber',
                      data['barberName'],
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    _buildRow(
                      Icons.calendar_today_outlined,
                      'Tanggal',
                      data['date'],
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    _buildRow(
                      Icons.access_time_outlined,
                      'Jam',
                      data['time'].toString().substring(0, 5),
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    _buildRow(Icons.payments_outlined, 'Total', formattedPrice),
                  ],
                ),
              ),

              const Spacer(),

              // ── TOMBOL BOOKING ───────────────────────────────────────
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: const Color(0xFFE5E5E5),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoadingSubmit ? null : _submit,
                child: isLoadingSubmit
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Booking Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InriaSerif',
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontFamily: 'InriaSerif',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'InriaSerif',
          ),
        ),
      ],
    );
  }
}
