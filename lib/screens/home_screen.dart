import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../widgets/base_background.dart';

// ── HomeScreen (StatefulWidget) ────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final Function(int, {String? service})? onChangeTab;
  final String username;

  const HomeScreen({super.key, this.onChangeTab, this.username = 'User'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _bookingDate = 'Tidak ada';
  bool _hasBooking = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    if (userId == 0) {
      setState(() {
        _hasBooking = false;
        _bookingDate = 'Tidak ada';
      });
      return;
    }

    final bookings = await BookingService.getBooking(userId);
    if (!mounted) return;

    final activeBookings = bookings.where(_isActiveBooking).toList();
    if (activeBookings.isNotEmpty) {
      final closest = _getClosestBooking(activeBookings);
      setState(() {
        _hasBooking = true;
        _bookingDate = _formatBookingDate(closest.date);
      });
    } else {
      setState(() {
        _hasBooking = false;
        _bookingDate = 'Tidak ada';
      });
    }
  }

  bool _isActiveBooking(BookingModel booking) {
    final status = booking.status.toLowerCase().trim();
    return status != 'cancel' && status != 'bayar';
  }

  BookingModel _getClosestBooking(List<BookingModel> bookings) {
    final now = DateTime.now();
    BookingModel? closest;
    Duration? closestDiff;

    for (final booking in bookings) {
      final normalizedTime = _normalizeTime(booking.time);
      final bookingDateTime = _parseBookingDateTime(booking.date, normalizedTime);
      if (bookingDateTime == null) continue;

      final diff = bookingDateTime.difference(now);
      final actualDiff = diff.isNegative ? diff.abs() : diff;

      if (closest == null) {
        closest = booking;
        closestDiff = actualDiff;
        continue;
      }

      final closestDateTime = _parseBookingDateTime(closest.date, _normalizeTime(closest.time));
      if (closestDateTime == null) continue;

      if (diff.isNegative && !closestDateTime.difference(now).isNegative) {
        continue;
      }
      if (!diff.isNegative && closestDateTime.difference(now).isNegative) {
        closest = booking;
        closestDiff = actualDiff;
        continue;
      }

      if (actualDiff < (closestDiff ?? Duration(days: 9999))) {
        closest = booking;
        closestDiff = actualDiff;
      }
    }

    return closest ?? bookings.first;
  }

  DateTime? _parseBookingDateTime(String date, String time) {
    try {
      return DateTime.parse('${date.trim()} ${time.trim()}');
    } catch (_) {
      return null;
    }
  }

  String _normalizeTime(String time) {
    final cleaned = time.trim().replaceAll('.', ':');
    final parts = cleaned.split(':');
    if (parts.length >= 2) {
      final hours = parts[0].padLeft(2, '0');
      final minutes = parts[1].padLeft(2, '0');
      final seconds = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
      return '$hours:$minutes:$seconds';
    }
    if (cleaned.length == 4) {
      final hours = cleaned.substring(0, 2);
      final minutes = cleaned.substring(2);
      return '$hours:$minutes:00';
    }
    return '00:00:00';
  }

  String _formatBookingDate(String date) {
    if (date.trim().isEmpty) return 'Tidak ada';
    try {
      final parsed = DateTime.parse(date);
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${parsed.day.toString().padLeft(2, '0')} ${monthNames[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: LOGO DAN NOTIFIKASI ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/barberinLogo.png',
                      height: 35,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BARBERIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                              fontFamily: 'InriaSerif',
                            ),
                          ),
                        );
                      },
                    ),
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- WELCOME TEXT ---
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    fontFamily: 'InriaSerif',
                  ),
                ),
                Text(
                  widget.username.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // --- INFO SUMMARY CARDS ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Tanggal Pesanan',
                        value: _bookingDate,
                        color: const Color(0xFF3F7DFF),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.star,
                        title: 'Rata-rata Rating',
                        value: '4.9/5',
                        color: const Color(0xFFF9C74F),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- QUICK ACTIONS ---
                const Text(
                  'Akses Cepat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'InriaSerif',
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildActionTile(
                        icon: Icons.event_available,
                        label: 'Booking Sekarang',
                        onTap: () {
                          if (widget.onChangeTab != null) {
                            widget.onChangeTab!(1);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionTile(
                        icon: Icons.info_outline,
                        label: 'Status Antrian',
                        onTap: () {
                          if (widget.onChangeTab != null) {
                            widget.onChangeTab!(2);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionTile(
                        icon: Icons.person_search,
                        label: 'Pilih Barber',
                        onTap: () {
                          if (widget.onChangeTab != null) {
                            widget.onChangeTab!(1, service: 'Classic Cut');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // --- SUBHEADER: FEATURED SERVICES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Layanan Unggulan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () {
                        if (widget.onChangeTab != null) widget.onChangeTab!(1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- HORIZONTAL SERVICES SLIDER ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildServiceCard(
                        imagePath: 'assets/images/classic_cut.jpg',
                        tag: 'POPULER',
                        title: 'Classic Cut (Adult)',
                        duration: '45 Menit',
                        price: 'Rp 40.000',
                        serviceNameForBooking: 'Classic Cut',
                      ),
                      const SizedBox(width: 15),
                      _buildServiceCard(
                        imagePath: 'assets/images/junior_cut.jpg',
                        tag: 'MURAH',
                        title: 'Junior Cut',
                        duration: '40 Menit',
                        price: 'Rp 35.000',
                        serviceNameForBooking: 'Junior Cut',
                      ),
                      const SizedBox(width: 15),
                      _buildServiceCard(
                        imagePath: 'assets/images/executive_cut.jpg',
                        tag: 'PREMIUM',
                        title: 'Executive Cut',
                        duration: '50 Menit',
                        price: 'Rp 50.000',
                        serviceNameForBooking: 'Executive Cut',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                if (_hasBooking) ...[
                  // --- LIVE STATUS BANNER ---
                  LiveStatusBanner(
                    onChangeTab: widget.onChangeTab,
                    queueCount: 2,
                    waitTime: '15 Menit lagi',
                  ),
                  const SizedBox(height: 25),
                ],

                // --- TIP BOX ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Catatan Cepat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InriaSerif',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Pastikan datang 10 menit lebih awal dan pilih layanan yang sesuai untuk pengalaman terbaik. Cek status antrian sebelum berangkat.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'InriaSerif',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String imagePath,
    required String tag,
    required String title,
    required String duration,
    required String price,
    required String serviceNameForBooking,
  }) {
    return InkWell(
      onTap: () {
        if (widget.onChangeTab != null) {
          widget.onChangeTab!(1, service: serviceNameForBooking);
        }
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white10,
      child: Container(
        width: 240,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color(0x66000000),
              BlendMode.darken,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xA6FFFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InriaSerif',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'InriaSerif',
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'InriaSerif',
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha((0.18 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'InriaSerif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white10,
      child: Container(
        width: 150,
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'InriaSerif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LiveStatusBanner (StatefulWidget terpisah) ─────────────────────────────
class LiveStatusBanner extends StatefulWidget {
  final Function(int, {String? service})? onChangeTab;
  final int queueCount;
  final String waitTime;

  const LiveStatusBanner({
    super.key,
    this.onChangeTab,
    this.queueCount = 0,
    this.waitTime = '',
  });

  @override
  State<LiveStatusBanner> createState() => _LiveStatusBannerState();
}

class _LiveStatusBannerState extends State<LiveStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.queueCount == 0;

    return InkWell(
      onTap: () {
        if (widget.onChangeTab != null) widget.onChangeTab!(2);
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(30, 30, 30, 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Zona kiri: ikon dalam circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF2B2B2B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_empty, color: Colors.white70),
            ),
            const SizedBox(width: 12),

            // Zona tengah: info antrean
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isEmpty ? 'Tidak ada antrean' : widget.waitTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'InriaSerif',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 0, 0, 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            FadeTransition(
                              opacity: _pulseAnimation,
                              child: const CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.queueCount} pelanggan sedang dalam antrian',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Zona kanan: arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
