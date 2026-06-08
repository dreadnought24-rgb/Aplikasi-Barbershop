import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/routes.dart';
import '../models/booking_model.dart';
import '../services/admin_service.dart';
import '../services/booking_service.dart';
import '../widgets/base_background.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

enum BookingFilter { inProgress, canceled, completed }

class _StatusScreenState extends State<StatusScreen> {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  List<bool> expanded = [];
  BookingFilter _selectedFilter = BookingFilter.inProgress;

  List<BookingModel> get _filteredBookings {
    return bookings.where((booking) {
      switch (_selectedFilter) {
        case BookingFilter.inProgress:
          return booking.status.toLowerCase() == 'belum bayar';
        case BookingFilter.canceled:
          return booking.status.toLowerCase() == 'cancel';
        case BookingFilter.completed:
          return booking.status.toLowerCase() == 'bayar';
      }
    }).toList();
  }

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
      expanded = List.generate(data.length, (_) => false);
      isLoading = false;
    });
  }

  Future<void> _cancelBooking(int index) async {
    final booking = bookings[index];
    final success = await AdminService.updateBookingStatus(
      id: booking.bookingId,
      status: 'cancel',
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil dibatalkan')),
      );
      await _loadBooking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membatalkan booking. Coba lagi.')),
      );
    }
  }

  Future<void> _confirmCancelBooking(int index) async {
    final booking = bookings[index];
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Batalkan Booking?', style: TextStyle(color: Colors.white, fontFamily: 'InriaSerif')),
          content: Text(
            'Booking tanggal ${booking.date} pukul ${_formatTime(booking.time)} akan dibatalkan.',
            style: const TextStyle(color: Colors.white70, fontFamily: 'InriaSerif'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'InriaSerif')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Batalkan', style: TextStyle(fontFamily: 'InriaSerif')),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _cancelBooking(index);
    }
  }

  // ── HELPER FUNCTION: PEMETAAN FOTO BARBER DARI ASSETS LOKAL ──
  String _getBarberAsset(String barberName) {
    final name = barberName.toLowerCase().trim();

    if (name.contains('andi')) {
      return 'assets/images/capster_andi.jpg';
    } else if (name.contains('budi')) {
      return 'assets/images/capster_budi.jpg';
    } else if (name.contains('ceri')) {
      return 'assets/images/capster_ceri.jpg';
    }

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

  Color _cardBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancel':
        return const Color(0xFF2B2B2B);
      case 'bayar':
        return const Color.fromRGBO(30, 30, 30, 0.85);
      case 'belum bayar':
      default:
        return const Color.fromRGBO(30, 30, 30, 0.85);
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
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : bookings.isEmpty
            ? _buildEmpty()
            : _buildList(),
      ),
    );
  }

  Widget _buildEmpty({BookingFilter? filter}) {
    final message = filter == null
        ? 'Belum ada booking aktif'
        : filter == BookingFilter.inProgress
            ? 'Belum ada booking dalam proses'
            : filter == BookingFilter.canceled
                ? 'Belum ada booking dibatalkan'
                : 'Belum ada booking selesai';

    final subtitle = filter == null
        ? 'Buat booking terlebih dahulu.'
        : 'Tidak ada booking dalam kategori ini.';

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
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.booking),
            child: const Text(
              'Booking Sekarang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'InriaSerif',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: BookingFilter.values.map((filter) {
        final selected = filter == _selectedFilter;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                filter == BookingFilter.inProgress
                    ? 'Dalam Proses'
                    : filter == BookingFilter.canceled
                        ? 'Di Batalkan'
                        : 'Selesai',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade300,
                  fontFamily: 'InriaSerif',
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xFF3F7DFF),
              backgroundColor: const Color(0xFF242424),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _buildFilterMenu(),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _filteredBookings.length,
            itemBuilder: (context, index) {
              final b = _filteredBookings[index];
              final bookingIndex = bookings.indexOf(b);
              final isExpanded = bookingIndex >= 0 && bookingIndex < expanded.length && expanded[bookingIndex];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (bookingIndex >= 0 && bookingIndex < expanded.length) {
                    setState(() {
                      expanded[bookingIndex] = !expanded[bookingIndex];
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBackgroundColor(b.status),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
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
                                    fontFamily: 'InriaSerif',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${b.date} • ${_formatTime(b.time)} • ${b.layanan}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Mencegah teks meluber jika terlalu panjang
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 20),
                        _infoRow(Icons.calendar_today_outlined, "Tanggal", b.date),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.access_time_outlined,
                          "Jam",
                          _formatTime(b.time),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.content_cut,
                          "Layanan",
                          b.layanan ?? '',
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(37, 37, 37, 0.6),
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
                                  fontFamily: 'InriaSerif',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _statusColor(b.status).withAlpha((0.15 * 255).round()),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _statusColor(b.status).withOpacity(0.3),
                                  ),
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
                        if (b.status.toLowerCase() != 'cancel') ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text(
                                'Batalkan Booking',
                                style: TextStyle(fontFamily: 'InriaSerif', fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _confirmCancelBooking(bookingIndex),
                            ),
                          ),
                        ],
                      ],
                      // Tambah tombol Ubah Jadwal hanya jika status belum bayar
                      if (b.status.toLowerCase() == 'belum bayar') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                            label: const Text(
                              'Ubah Jadwal',
                              style: TextStyle(
                                fontFamily: 'InriaSerif',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRoutes.booking,
                                arguments: {
                                  'mode': 'edit',
                                  'bookingId': b.bookingId,
                                  'pencukurId': b.pencukurId, // ← sekarang ada
                                  'currentDate': b.date,
                                  'currentTime': b.time,
                                },
                              );

                              if (result == true && mounted) {
                                _loadBooking();
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(37, 37, 37, 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'InriaSerif',
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
