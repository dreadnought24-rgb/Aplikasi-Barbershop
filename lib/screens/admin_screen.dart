//skip dulu

import 'package:flutter/material.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  final int adminUserId;
  const AdminScreen({super.key, this.adminUserId = 0});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String selectedBarberId = '';
  String adminBarberName = '';
  bool isLoading = true;
<<<<<<< HEAD
  List<BarberModel> barberList = [];
=======
  bool isUpdating = false;
  List<BarberModel> barberList = [];//?
>>>>>>> 8739a2ba6529c983cfe42196b0fe71bf8d5474d9
  List<dynamic> queueList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      if (widget.adminUserId > 0) {
        final barber = await AdminService.getBarberData(widget.adminUserId);
        if (!mounted) return;
        if (barber != null) {
          setState(() {
            barberList = [barber];
            selectedBarberId = barber.id;
            adminBarberName = barber.nama;
          });
          await _loadQueue();
        } else {
          setState(() {
            isLoading = false;
          });
          _snack('Data barber tidak ditemukan untuk akun ini.', isError: true);
        }
        return;
      }
      // Fallback: semua barber
      final all = await BarberService.getBarber();
      if (!mounted) return;
      setState(() {
        barberList = all;
        if (all.isNotEmpty) {
          selectedBarberId = all.first.id;
          adminBarberName = all.first.nama;
        }
      });
      await _loadQueue();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _snack('Gagal memuat data: $e', isError: true);
    }
  }

  Future<void> _loadQueue() async {
    if (selectedBarberId.isEmpty) {
      setState(() {
        queueList = [];
        isLoading = false;
      });
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await AdminService.getBarberQueue(selectedBarberId);
      if (!mounted) return;
      setState(() {
        queueList = data ?? [];
        queueList.sort((a, b) => _queueNum(a).compareTo(_queueNum(b)));
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        queueList = [];
        isLoading = false;
      });
      _snack('Gagal memuat antrian: $e', isError: true);
    }
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    final ok = await AdminService.updateBookingStatus(
      id: bookingId,
      status: status,
    );
    if (!mounted) return;
    if (ok) {
      _snack(
        status == 'bayar' ? 'Pembayaran dikonfirmasi ✓' : 'Booking dibatalkan',
      );
      await _loadQueue();
    } else {
      _snack('Gagal memperbarui status.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _val(dynamic item, List<String> keys) {
    if (item is Map<String, dynamic>) {
      for (final k in keys) {
        final v = item[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    return '';
  }

  int _queueNum(dynamic item) =>
      int.tryParse(_val(item, ['queue_number'])) ?? 999;
  String _name(dynamic item) =>
      _val(item, ['nama_pelanggan', 'nama', 'name']).trim();
  String _date(dynamic item) => _val(item, ['booking_date', 'date', 'tanggal']);
  String _time(dynamic item) {
    final t = _val(item, ['booking_time', 'time', 'jam']);
    if (t.isEmpty) return '-';
    final p = t.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : t;
  }

  String _bookingId(dynamic item) => _val(item, ['id', 'booking_id']);

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminBarberName.isNotEmpty ? 'Antrian – $adminBarberName' : 'Admin',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadQueue,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector barber (hanya kalau fallback multi-barber)
                if (barberList.length > 1) _buildBarberChips(),

                // Badge jumlah antrian
                if (queueList.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      '${queueList.length} pelanggan menunggu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // List antrian
                Expanded(
                  child: queueList.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.content_cut,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada antrian',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: queueList.length,
                          separatorBuilder: (_, _i) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = queueList[index];
                            final isFirst = index == 0;
                            final name = _name(item);
                            final bookingId = _bookingId(item);
                            return _QueueCard(
                              number: index + 1,
                              name: name.isEmpty
                                  ? 'Pelanggan ${index + 1}'
                                  : name,
                              date: _date(item),
                              time: _time(item),
                              bookingId: bookingId,
                              isFirst: isFirst,
                              onBayar: () => _updateStatus(bookingId, 'bayar'),
                              onCancel: () =>
                                  _confirmCancel(context, name, bookingId),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBarberChips() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: barberList.map((b) {
          final sel = b.id == selectedBarberId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(b.nama),
              selected: sel,
              selectedColor: Colors.black,
              labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
              onSelected: (_) {
                setState(() {
                  selectedBarberId = b.id;
                  adminBarberName = b.nama;
                });
                _loadQueue();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String name, String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: Text('Booking atas nama $name akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(bookingId, 'cancel');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

// ── Queue Card ────────────────────────────────────────────────────────────────

class _QueueCard extends StatelessWidget {
  final int number;
  final String name;
  final String date;
  final String time;
  final String bookingId;
  final bool isFirst;
  final VoidCallback onBayar;
  final VoidCallback onCancel;

  const _QueueCard({
    required this.number,
    required this.name,
    required this.date,
    required this.time,
    required this.bookingId,
    required this.isFirst,
    required this.onBayar,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isFirst ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFirst ? Colors.green : Colors.grey.shade300,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: nomor + nama + badge
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isFirst ? Colors.green : Colors.black,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (bookingId.isNotEmpty)
                        Text(
                          'ID #$bookingId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFirst ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    isFirst ? 'Dilayani' : 'Menunggu',
                    style: TextStyle(
                      fontSize: 12,
                      color: isFirst
                          ? Colors.green.shade800
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Tanggal & jam
            if (date.isNotEmpty || time != '-') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date.isNotEmpty ? date : '-',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.access_time_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBayar,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Sudah Bayar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
