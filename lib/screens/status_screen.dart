import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/routes.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../widgets/base_background.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    final data = await BookingService.getBooking(userId);

    if (!mounted) return;
    setState(() {
      bookings = data;
      expanded = List.generate(
        data.length,
        (_) => false,
      );
      isLoading = false;
    });
  }

  // ── HELPER FUNCTION: PEMETAAN FOTO BARBER DARI ASSETS LOKAL ──
  String _getBarberAsset(String barberName) {
    // Mengubah string nama barber menjadi huruf kecil semua agar aman dicocokkan
    final name = barberName.toLowerCase().trim();

    if (name.contains('andi')) {
      return 'images/capster_andi.jpg'; // <── Sesuaikan path & nama file lokalmu
    } else if (name.contains('budi')) {
      return 'images/capster_budi.jpg';
    } else if (name.contains('ceri')) {
      return 'images/capster_ceri.jpg';
    } 
    
    // Kembalikan gambar default jika nama barber tidak terdaftar di atas
    return 'assets/default_avatar.png'; 
  }

  String _formatTime(String time) {
    final t = time.trim().replaceAll('.', ':');
    final parts = t.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : t;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'bayar':
        return Colors.green;
      case 'cancel':
        return Colors.red;
      case 'belum bayar':
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'bayar':
        return 'Sudah Bayar ✓';
      case 'cancel':
        return 'Dibatalkan';
      case 'belum bayar':
        return 'Menunggu';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Status Booking',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 24, 
              fontFamily: 'InriaSerif', 
              fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : bookings.isEmpty
                ? _buildEmpty()
                : _buildList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada booking aktif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'InriaSerif'),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat booking terlebih dahulu.',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.booking),
            child: const Text('Booking Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'InriaSerif')),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              expanded[index] = !expanded[index];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // ── MENGGANTI ICON GUNTING MENJADI FOTO ASSET BARBER ──
                    CircleAvatar(
                      radius: 24, // Sedikit diperbesar agar fotonya jelas terlihat
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: AssetImage(_getBarberAsset(b.barber)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.barber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'InriaSerif'
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${b.date} • ${_formatTime(b.time)}",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
                if (expanded[index]) ...[
                  const SizedBox(height: 20),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    "Tanggal",
                    b.date,
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.access_time_outlined,
                    "Jam",
                    _formatTime(b.time),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.confirmation_number_outlined,
                    "No Antrian",
                    b.queue.toString(),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'InriaSerif'
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(b.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _statusColor(b.status).withOpacity(0.3)),
                          ),
                          child: Text(
                            _statusLabel(b.status),
                            style: TextStyle(
                              color: _statusColor(b.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF252525).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey, fontFamily: 'InriaSerif'),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}