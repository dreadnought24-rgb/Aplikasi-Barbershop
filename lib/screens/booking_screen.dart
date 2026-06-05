import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/booking_service.dart';
import '../config/routes.dart';
import '../controllers/booking_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController _controller = BookingController();

  List<BarberModel> barberList = [];
  List<String> slotList = [];
  String? selectedBarberId;
  String? selectedSlot;
  DateTime? selectedDate;
  bool isLoadingBarber = true;
  bool isLoadingSlot = false;
  bool isLoadingSubmit = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Baca user_id dari SharedPreferences yang disimpan saat login
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;

    if (_userId == 0 && mounted) {
      // Belum login, redirect ke login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    try {
      final data = await BarberService.getBarber();
      if (!mounted) return;
      setState(() {
        barberList = data;
        selectedBarberId = barberList.isNotEmpty ? barberList.first.id : null;
        isLoadingBarber = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingBarber = false);
      _snack('Gagal memuat daftar barber: $e', isError: true);
    }
  }

  Future<void> _loadSlots() async {
    if (selectedDate == null || selectedBarberId == null) return;
    setState(() {
      isLoadingSlot = true;
      selectedSlot = null;
      slotList = [];
    });

    final data = await BookingService.getAvailableSlots(
      tanggal: _dateForApi(selectedDate!),
      idPencukur: selectedBarberId!,
    );

    if (!mounted) return;
    setState(() {
      slotList = data;
      isLoadingSlot = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Pilih tanggal booking',
    );
    if (date != null && mounted) {
      setState(() => selectedDate = date);
      await _loadSlots();
    }
  }

  String _dateForApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateDisplay(DateTime d) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  Future<void> _submit() async {
    if (selectedBarberId == null) {
      _snack('Pilih barber terlebih dahulu.', isError: true);
      return;
    }
    if (selectedDate == null) {
      _snack('Pilih tanggal terlebih dahulu.', isError: true);
      return;
    }
    if (selectedSlot == null) {
      _snack('Pilih jam dari slot yang tersedia.', isError: true);
      return;
    }

    setState(() => isLoadingSubmit = true);

    final isSuccess = await _controller.createBooking(
      userId: _userId.toString(),
      pencukurId: selectedBarberId!,
      bookingDate: _dateForApi(selectedDate!),
      bookingTime: '$selectedSlot:00', // HH:mm:ss untuk kolom TIME MySQL
    );

    if (!mounted) return;
    setState(() => isLoadingSubmit = false);

    _snack(_controller.statusMessage, isError: !isSuccess);

    if (isSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.status);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Booking')),
      body: isLoadingBarber
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── 1. Pilih Barber ──────────────────────────────────────────
                _label('Pilih Barber'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedBarberId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.content_cut),
                  ),
                  items: barberList
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.nama)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedBarberId = val;
                      selectedSlot = null;
                      slotList = [];
                    });
                    _loadSlots();
                  },
                ),
                const SizedBox(height: 20),

                // ── 2. Pilih Tanggal ─────────────────────────────────────────
                _label('Pilih Tanggal'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? _dateDisplay(selectedDate!)
                              : 'Tap untuk pilih tanggal',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDate != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 3. Slot Jam ──────────────────────────────────────────────
                _label('Pilih Jam Booking'),
                const SizedBox(height: 8),
                if (isLoadingSlot)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (selectedDate == null || selectedBarberId == null)
                  _hint('Pilih barber dan tanggal untuk melihat slot tersedia.')
                else if (slotList.isEmpty)
                  _hint('Tidak ada slot tersedia untuk barber dan tanggal ini.')
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: slotList.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),

                // ── 4. Submit ────────────────────────────────────────────────
                const SizedBox(height: 32),

                // ── 5. Submit ────────────────────────────────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
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
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
    ),
  );
}
