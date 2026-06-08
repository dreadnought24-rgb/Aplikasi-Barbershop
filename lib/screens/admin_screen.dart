// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/admin_service.dart';
import '../widgets/base_background.dart';
import '../services/profile_service.dart';
import '../services/booking_service.dart';
// import '../services/notification_service.dart';

class AdminScreen extends StatefulWidget {
  final int adminUserId;
  const AdminScreen({super.key, this.adminUserId = 0});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  //variable
  String selectedBarberId = '';
  String adminBarberName = '';
  bool isLoading = true;
  List<BarberModel> barberList = [];
  List<dynamic> queueList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }


//fungsi Load Data
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
          setState(() => isLoading = false);
          _snack('Data barber tidak ditemukan untuk akun ini.', isError: true);
        }
        return;
      }
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
      setState(() => isLoading = false);
      _snack('Gagal memuat data: $e', isError: true);
    }
  }
//fungsi Load Data end

//fungsi Load Queue
  Future<void> _loadQueue() async {
    if (selectedBarberId.isEmpty) {
      setState(() { queueList = []; isLoading = false; });
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await AdminService.getBarberQueue(selectedBarberId);
      if (!mounted) return;

      // 1. Dapatkan tanggal hari ini dengan format YYYY-MM-DD
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // 2. Filter data mentah agar hanya menampilkan antrian hari ini saja
      final rawList = data ?? [];
      final todayQueue = rawList.where((item) => _date(item) == todayStr).toList();

      setState(() {
        // 3. Masukkan data yang sudah difilter ke dalam queueList
        queueList = todayQueue;
        queueList.sort((a, b) => _queueNum(a).compareTo(_queueNum(b)));
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { queueList = []; isLoading = false; });
      _snack('Gagal memuat antrian: $e', isError: true);
    }
  }
//fungsi Load Queue

//update Status User
Future<void> _updateStatus(String bookingId, String status) async {
  print('_updateStatus dipanggil: bookingId=$bookingId, status=$status');
  
  final ok = await AdminService.updateBookingStatus(id: bookingId, status: status);
  print('updateBookingStatus result: $ok');
  
  if (!mounted) return;

  if (ok) {
    print('DEBUG bookingId: $bookingId');
    print('DEBUG pencukurId: $selectedBarberId');

    await BookingService.updateQueue(
      bookingId: bookingId,
      pencukurId: selectedBarberId,
    );

    await BookingService.checkBarberLoad();

    // if (status == 'cancel'){
    //   await NotificationService.cancelNotification(int.tryParse(bookingId) ?? 0);
    // }

    _snack(status == 'bayar' ? 'Pembayaran dikonfirmasi ✓' : 'Booking dibatalkan');
    await _loadQueue();
  } else {
    _snack('Gagal memperbarui status.', isError: true);
  }
}
//update Status User end

//Desain
  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
    ));
  }
//Desain end

  String _val(dynamic item, List<String> keys) {
    if (item is Map<String, dynamic>) {
      for (final k in keys) {
        final v = item[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    return '';
  }

  int _queueNum(dynamic item) => int.tryParse(_val(item, ['queue_number'])) ?? 999;
  String _name(dynamic item) => _val(item, ['nama_pelanggan', 'nama', 'name']).trim();
  String _date(dynamic item) => _val(item, ['booking_date', 'date', 'tanggal']);
  String _time(dynamic item) {
    final t = _val(item, ['booking_time', 'time', 'jam']);
    if (t.isEmpty) return '-';
    final p = t.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : t;
  }
  String _bookingId(dynamic item) => _val(item, ['id', 'booking_id']);
  String _queueLabel(dynamic item) => _val(item, ['queue_number']);


  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // X button
                    // GestureDetector(
                    //   onTap: () {
                    //     showDialog(
                    //       context: context,
                    //       builder: (ctx) => AlertDialog(
                    //         backgroundColor: const Color(0xFF1E1E1E),
                    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    //         title: const Text('Keluar Aplikasi?',
                    //             style: TextStyle(color: Colors.white, fontFamily: 'InriaSerif')),
                    //         content: const Text('Yakin ingin menutup aplikasi?',
                    //             style: TextStyle(color: Colors.grey)),
                    //         actions: [
                    //           TextButton(
                    //             onPressed: () => Navigator.pop(ctx),
                    //             child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    //           ),
                    //           TextButton(
                    //             onPressed: () {
                    //               Navigator.pop(ctx);
                    //               SystemNavigator.pop();
                    //             },
                    //             child: const Text('Keluar',
                    //                 style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     width: 36,
                    //     height: 36,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white10,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: const Icon(Icons.close, color: Colors.white, size: 18),
                    //   ),
                    // ),
                    const Spacer(),
                    // Logout button
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Logout',
                                style: TextStyle(color: Colors.white, fontFamily: 'InriaSerif')),
                            content: const Text('Yakin ingin keluar dari akun ini?',
                                style: TextStyle(color: Colors.grey)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await ProfileService().logout();
                                  if (!mounted) return;
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil('/login', (route) => false);
                                },
                                child: const Text('Logout',
                                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'InriaSerif',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title: List Customer - NamaBarber ──

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'List Customer - ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    Text(
                      adminBarberName.isNotEmpty ? adminBarberName : 'Admin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    const Spacer(),
                    // Refresh icon
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                      onPressed: isLoading ? null : _loadQueue,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Barber chips (multi barber fallback)
              if (barberList.length > 1) _buildBarberChips(),

              const SizedBox(height: 12),

              // ── Queue count ──
              if (queueList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${queueList.length} pelanggan menunggu',
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // ── List ──
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : queueList.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: queueList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = queueList[index];
                              final isFirst = index == 0;
                              final name = _name(item);
                              final bookingId = _bookingId(item);
                              return _QueueCard(
                                queueLabel: _queueLabel(item),
                                number: index + 1,
                                name: name.isEmpty ? 'Pelanggan ${index + 1}' : name,
                                date: _date(item),
                                time: _time(item),
                                bookingId: bookingId,
                                isFirst: isFirst,
                                onBayar: () => _updateStatus(bookingId, 'bayar'),                                     //TOMBOL BAYAR
                                onCancel: () => _confirmCancel(context, name, bookingId),                             //TOMBOL CANCEL
                                onStatusChange: (newStatus) => _updateStatus(bookingId, newStatus),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 64, color: Colors.white24),
          const SizedBox(height: 12),
          const Text('Belum ada antrian',
              style: TextStyle(fontSize: 16, color: Colors.white38, fontFamily: 'InriaSerif')),
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
              selectedColor: Colors.white,
              backgroundColor: Colors.white12,
              labelStyle: TextStyle(
                color: sel ? Colors.black : Colors.white70,
                fontFamily: 'InriaSerif',
              ),
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
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Booking?',
            style: TextStyle(color: Colors.white, fontFamily: 'InriaSerif')),
        content: Text('Booking atas nama $name akan dibatalkan.',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(bookingId, 'cancel');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

// ── Queue Card ────────────────────────────────────────────────────────────────

class _QueueCard extends StatefulWidget {
  final String queueLabel;
  final int number;
  final String name;
  final String date;
  final String time;
  final String bookingId;
  final bool isFirst;
  final VoidCallback onBayar;
  final VoidCallback onCancel;
  final Function(String) onStatusChange;

  const _QueueCard({
    required this.queueLabel,
    required this.number,
    required this.name,
    required this.date,
    required this.time,
    required this.bookingId,
    required this.isFirst,
    required this.onBayar,
    required this.onCancel,
    required this.onStatusChange,
  });

  @override
  State<_QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<_QueueCard> {
  // 'menunggu' atau 'dilayani' — hanya tampilan lokal di card
  // late String _localStatus;

  @override
  // void initState() {
  //   super.initState();
  //   _localStatus = widget.isFirst ? 'dilayani' : 'menunggu';
  // }

  // Color get _statusColor =>
  //     _localStatus == 'dilayani' ? const Color(0xFF4CAF50) : Colors.white54;

  // Color get _statusBg =>
  //     _localStatus == 'dilayani'
  //         ? const Color(0xFF4CAF50).withOpacity(0.15)
  //         : Colors.white.withOpacity(0.08);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isFirst
              ? const Color(0xFF4CAF50).withOpacity(0.4)
              : Colors.white10,
          width: widget.isFirst ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris atas: avatar + nama + queue label + dropdown status ──
          Row(
            children: [
              // Avatar inisial
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white12,
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nama + queue number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A-${widget.queueLabel.isNotEmpty ? widget.queueLabel : widget.number}',
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // ── Dropdown status (menunggu / dilayani) ──
              // GestureDetector(
              //   onTapDown: (details) async {
              //     final result = await showMenu<String>(
              //       context: context,
              //       position: RelativeRect.fromLTRB(
              //         details.globalPosition.dx,
              //         details.globalPosition.dy,
              //         details.globalPosition.dx + 1,
              //         details.globalPosition.dy + 1,
              //       ),
              //       color: const Color(0xFF2A2A2A),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //       items: [
              //         PopupMenuItem(
              //           value: 'menunggu',
              //           child: Row(
              //             children: [
              //               Icon(Icons.hourglass_empty, size: 16, color: Colors.white54),
              //               const SizedBox(width: 8),
              //               const Text('Menunggu', style: TextStyle(color: Colors.white70)),
              //             ],
              //           ),
              //         ),
              //         PopupMenuItem(
              //           value: 'dilayani',
              //           child: Row(
              //             children: [
              //               Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF4CAF50)),
              //               const SizedBox(width: 8),
              //               const Text('Dilayani', style: TextStyle(color: Colors.white70)),
              //             ],
              //           ),
              //         ),
              //       ],
              //     );
              //     if (result != null && mounted) {
              //       setState(() => _localStatus = result);
              //       // 'dilayani'/'menunggu' hanya UI lokal, tidak dikirim ke DB
              //       // DB hanya diupdate lewat tombol Sudah Bayar / Cancel
              //     }
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: _statusBg,
              //       borderRadius: BorderRadius.circular(20),
              //       border: Border.all(color: _statusColor.withOpacity(0.4)),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           _localStatus == 'dilayani' ? 'Dilayani' : 'Menunggu',
              //           style: TextStyle(
              //             color: _statusColor,
              //             fontSize: 12,
              //             fontWeight: FontWeight.w600,
              //             fontFamily: 'InriaSerif',
              //           ),
              //         ),
              //         const SizedBox(width: 4),
              //         Icon(Icons.keyboard_arrow_down, color: _statusColor, size: 14),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),

          // ── Tanggal & jam ──
          if (widget.date.isNotEmpty || widget.time != '-') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  widget.date.isNotEmpty ? widget.date : '-',
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time_outlined, size: 13, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  widget.time,
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          const SizedBox(height: 12),

          // ── Tombol aksi ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onBayar,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Sudah Bayar', style: TextStyle(fontFamily: 'InriaSerif')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel', style: TextStyle(fontFamily: 'InriaSerif')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}