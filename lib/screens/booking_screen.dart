import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';
import '../config/routes.dart';
// import '../controllers/booking_controller.dart';
import '../widgets/base_background.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // final BookingController _controller = BookingController();

  List<BarberModel> barberList = [];
  List<String> slotList = [];
  String? selectedBarberId;
  String? selectedSlot;
  DateTime selectedDate = DateTime.now();
  String? _editBookingId;
  bool _isEditMode = false;
  String selectedService = 'Classic Cut';
  int servicePrice = 40000;
  bool isLoadingBarber = true;
  bool isLoadingSlot = false;
  bool isLoadingSubmit = false;
  int _userId = 0;


  //membuat tanggal max 7 hari kedepan dari hari ini
  final List<DateTime> _daysList = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );


  //DESAIN Tampilan gambar Barber
  final Map<String, Map<String, String>> _capsterDetails = {
    'Andi': {
      'image': 'assets/images/capster_andi.jpg',
      'quote': '"Precision is the only standard."',
    },
    'Budi': {
      'image': 'assets/images/capster_budi.jpg',
      'quote': '"Style is a reflection of your attitude."',
    },
    'Ceri': {
      'image': 'assets/images/capster_ceri.jpg',
      'quote': '"Sharp look, sharp mind."',
    },
  };


  @override
  void initState() {                  //fungsi initstate menjalankan _init
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;

    if (_userId == 0 && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    // Cek apakah mode edit
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['mode'] == 'edit') {
      _isEditMode = true;
      _editBookingId = args['bookingId'];
      selectedBarberId = args['pencukurId'];

      // Set tanggal dan jam sekarang dari data lama
      if (args['currentDate'] != null) {
        selectedDate = DateTime.parse(args['currentDate']);
      }
    }

    try {
      final data = await BarberService.getBarber();
      if (!mounted) return;
      setState(() {
        barberList = data;
        if (!_isEditMode) {
          selectedBarberId = barberList.isNotEmpty ? barberList.first.id : null;
        }
        isLoadingBarber = false;
      });
      _loadSlots();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingBarber = false);
      _snack('Gagal memuat daftar barber: $e', isError: true);
    }
  }

  Future<void> _loadSlots() async {
    if (selectedBarberId == null) return;
    setState(() {
      isLoadingSlot = true;
      selectedSlot = null;
      slotList = [];
    });

    try {
      final data = await BookingService.getAvailableSlots(
        tanggal: _dateForApi(selectedDate),
        idPencukur: selectedBarberId!,
      );

      if (!mounted) return;
      setState(() {
        slotList = data;
        isLoadingSlot = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingSlot = false);
    }
  }

  String _dateForApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _getNamaHari(int weekday) {
    const hari = ['', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return hari[weekday];
  }

  List<String> _getSlotsByTimeOfDay(bool isMorning) {
    return slotList.where((slot) {
      final hour = int.tryParse(slot.split(':').first) ?? 0;
      return isMorning ? hour < 12 : hour >= 12;
    }).toList();
  }

  Map<String, String> _getSelectedCapsterDetails() {
    if (selectedBarberId == null || barberList.isEmpty) {
      return {
        'image': 'images/capster_andi.jpg',
        'quote': '"Precision is the only standard."',
      };
    }

    final currentBarber = barberList.firstWhere(
      (b) => b.id == selectedBarberId,
      orElse: () => barberList.first,
    );

    return _capsterDetails[currentBarber.nama] ??
        {
          'image': 'images/capster_andi.jpg',
          'quote': '"Precision is the only standard."',
        };
  }

  //bagian submit

  // Future<void> _submit() async {
  //   if (selectedBarberId == null) {
  //     _snack('Pilih barber terlebih dahulu.', isError: true);
  //     return;
  //   }
  //   if (selectedSlot == null) {
  //     _snack('Pilih jam dari slot yang tersedia.', isError: true);
  //     return;
  //   }

  //   setState(() => isLoadingSubmit = true);

  //   // Mengirim string murni ('Classic Cut', 'Junior Cut', atau 'Executive Cut') ke Controller
  //   final isSuccess = await _controller.createBooking(
  //     userId: _userId.toString(),
  //     pencukurId: selectedBarberId!,
  //     bookingDate: _dateForApi(selectedDate),
  //     bookingTime: '$selectedSlot:00',
  //     service: selectedService,
  //   );

  //   if (!mounted) return;
  //   setState(() => isLoadingSubmit = false);

  //   _snack(_controller.statusMessage, isError: !isSuccess);

  //   if (isSuccess) {
  //     await _loadSlots();
  //     Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
  //   }
  // }

  //bagian submit

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDetails = _getSelectedCapsterDetails();

    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _isEditMode ? 'Ubah Jadwal' : 'Pilih Waktu',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'InriaSerif',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoadingBarber
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 200,
                    ),
                    children: [
                      // ── 1. CARD CAPSTER DENGAN DATA DINAMIS ─────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pilihan Capster',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontFamily: 'InriaSerif',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedBarberId,
                                      dropdownColor: const Color(0xFF222222),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      ),
                                      isDense: true,
                                      alignment: Alignment.centerLeft,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'InriaSerif',
                                      ),
                                      items: barberList.map((barber) {
                                        return DropdownMenuItem<String>(
                                          value: barber.id,
                                          child: Text(barber.nama),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedBarberId = val;
                                        });
                                        _loadSlots();
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentDetails['quote']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(currentDetails['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ── 2. HORIZONTAL DATE PICKER ───────────────────────────
                      _sectionLabel(Icons.calendar_today, 'Pilih Tanggal'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 75,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _daysList.length,
                          itemBuilder: (context, index) {
                            final day = _daysList[index];
                            final isSelected =
                                day.day == selectedDate.day &&
                                day.month == selectedDate.month;
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedDate = day);
                                _loadSlots();
                              },
                              child: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE5E5E5)
                                      : const Color(
                                          0xFF1E1E1E,
                                        ).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getNamaHari(day.weekday),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ── 3. SERVICES SECTION ──────────────────────────────────
                      // String nama layanan di bawah ini sudah sama persis dengan opsi Enum MySQL Anda
                      _sectionLabel(Icons.content_cut, 'Services'),
                      const SizedBox(height: 12),
                      _buildServiceItem(
                        'Junior Cut',
                        'Cut + Hairstyling',
                        'Rp 35.000',
                        'E.T 40 Menit',
                        35000,
                      ),
                      _buildServiceItem(
                        'Classic Cut',
                        'Cut + Hairstyling',
                        'Rp 40.000',
                        'E.T 45 Menit',
                        40000,
                      ),
                      _buildServiceItem(
                        'Executive Cut',
                        'Cut + Shower + Hairstyling',
                        'Rp 50.000',
                        'E.T 50 Menit',
                        50000,
                      ),
                      const SizedBox(height: 25),

                      // ── 4. SLOT JAM PAGI ─────────────────────────────────────
                      _sectionLabel(Icons.light_mode_outlined, 'Pagi'),
                      const SizedBox(height: 12),
                      isLoadingSlot
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _buildTimeSlots(_getSlotsByTimeOfDay(true)),
                      const SizedBox(height: 25),

                      // ── 5. SLOT JAM SIANG/SORE ───────────────────────────────
                      _sectionLabel(Icons.wb_twilight, 'Siang/Sore'),
                      const SizedBox(height: 12),
                      isLoadingSlot
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _buildTimeSlots(_getSlotsByTimeOfDay(false)),
                    ],
                  ),

                  // ── BOTTOM FLOATING ACTION BAR ──────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414).withOpacity(0.95),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedService,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'InriaSerif',
                                    ),
                                  ),
                                  Text(
                                    barberList.isNotEmpty
                                        ? barberList
                                              .firstWhere(
                                                (b) => b.id == selectedBarberId,
                                                orElse: () => barberList.first,
                                              )
                                              .nama
                                        : 'Ken Paves',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontFamily: 'InriaSerif',
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp ${servicePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              backgroundColor: const Color(0xFFE5E5E5),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (selectedBarberId == null) {
                                _snack(
                                  'Pilih barber terlebih dahulu.',
                                  isError: true,
                                );
                                return;
                              }
                              if (selectedSlot == null) {
                                _snack(
                                  'Pilih jam dari slot yang tersedia.',
                                  isError: true,
                                );
                                return;
                              }

                              final selectedBarberName = barberList
                                  .firstWhere((b) => b.id == selectedBarberId)
                                  .nama;

                              if (_isEditMode) {
                                // Mode edit → navigasi ke konfirmasi dengan data edit
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.konfirmasi,
                                  arguments: {
                                    'mode': 'edit',
                                    'bookingId': _editBookingId!,
                                    'userId': _userId.toString(),
                                    'barberId': selectedBarberId!,
                                    'barberName': selectedBarberName,
                                    'date': _dateForApi(selectedDate),
                                    'time': '$selectedSlot:00',
                                    'service': selectedService,
                                    'price': servicePrice,
                                  },
                                );
                              } else {
                                // Mode normal → seperti sebelumnya
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.konfirmasi,
                                  arguments: {
                                    'mode': 'new',
                                    'userId': _userId.toString(),
                                    'barberId': selectedBarberId!,
                                    'barberName': selectedBarberName,
                                    'date': _dateForApi(selectedDate),
                                    'time': '$selectedSlot:00',
                                    'service': selectedService,
                                    'price': servicePrice,
                                  },
                                );
                              }
                            },

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
                                        'Konfirmasi Pesanan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'InriaSerif',
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'InriaSerif',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(
    String name,
    String desc,
    String price,
    String duration,
    int rawPrice,
  ) {
    final isSelected = selectedService == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = name;
          servicePrice = rawPrice;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5E5E5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(List<String> slots) {
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Tidak ada slot tersedia (Sudah dipesan)',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => selectedSlot = slot),
          child: Container(
            width: (MediaQuery.of(context).size.width - 64) / 3,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.transparent
                  : const Color(0xFF1E1E1E).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE5E5E5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
