//skip dulu

import 'package:flutter/material.dart';
import '../models/barber_model.dart';
import '../services/barber_service.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String selectedBarberId = '';
  bool isLoading = true;
  bool isUpdating = false;
  List<BarberModel> barberList = [];//?
  List<dynamic> queueList = [];

  @override
  void initState() {
    super.initState();
    loadBarbersAndQueue();
  }

  Future<void> loadBarbersAndQueue() async {
    try {
      setState(() {
        isLoading = true;
      });

      final barbers = await BarberService.getBarber();

      if (!mounted) return;

      setState(() {
        barberList = barbers;
        if (barberList.isNotEmpty) {
          final hasSelected = barberList.any(
            (barber) => barber.id == selectedBarberId,
          );
          if (!hasSelected) {
            selectedBarberId = barberList.first.id;
          }
        }
      });

      await loadQueue();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        barberList = [];
        queueList = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat barber: $e')));
    }
  }

  Future<void> loadQueue() async {
    if (selectedBarberId.isEmpty) {
      if (!mounted) return;
      setState(() {
        queueList = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await AdminService.getBarberQueue(selectedBarberId);

      if (!mounted) return;

      setState(() {
        queueList = data ?? [];
        queueList.sort(
          (a, b) => _queueNumberOf(a).compareTo(_queueNumberOf(b)),
        );
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        queueList = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat antrean: $e')));
    }
  }

  Future<void> markNextAsDone() async {
    if (queueList.isEmpty || isUpdating) {
      return;
    }

    final firstItem = queueList.first;
    final bookingId = _valueOf(firstItem, ['id', 'booking_id', 'bookingId']);

    if (bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID booking tidak ditemukan untuk antrian teratas.'),
        ),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    final success = await AdminService.updateBookingStatus(
      id: bookingId,
      status: 'selesai',
    );

    if (!mounted) return;

    setState(() {
      isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Antrian teratas sudah selesai, data berikutnya naik ke atas.'
              : 'Gagal memperbarui status antrian.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      await loadQueue();
    }
  }

  String _valueOf(dynamic item, List<String> keys) {
    if (item is Map<String, dynamic>) {
      for (final key in keys) {
        final value = item[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return '';
  }

  int _queueNumberOf(dynamic item) {
    final raw = _valueOf(item, ['queue_number', 'queue', 'antrian']);
    return int.tryParse(raw) ?? 999999;
  }

  String _customerNameOf(dynamic item) {
    return _valueOf(item, [
      'nama_pelanggan',
      'customer_name',
      'nama_customer',
      'nama',
      'name',
    ]).trim();
  }

  String _timeOf(dynamic item) {
    return _valueOf(item, ['booking_time', 'time', 'jam']);
  }

  String _dateOf(dynamic item) {
    return _valueOf(item, ['booking_date', 'date', 'tanggal']);
  }

  String _statusOf(dynamic item) {
    final status = _valueOf(item, ['status']);
    return status.isEmpty ? 'menunggu' : status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Queue'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadQueue,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F7F7), Color(0xFFECEFF1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queue Barber',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih barber, lihat urutan pelanggan, lalu tandai antrian paling atas selesai agar data berikutnya naik.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: barberList.map((barber) {
                    return ChoiceChip(
                      label: Text(barber.nama),
                      selected: selectedBarberId == barber.id,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          selectedBarberId = barber.id;
                        });
                        loadQueue();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : queueList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.content_cut,
                                size: 72,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada data antrian untuk barber ini.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.people_alt,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          barberList.isNotEmpty
                                              ? barberList
                                                    .firstWhere(
                                                      (barber) =>
                                                          barber.id ==
                                                          selectedBarberId,
                                                      orElse: () =>
                                                          barberList.first,
                                                    )
                                                    .nama
                                              : 'Barber $selectedBarberId',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${queueList.length} pelanggan menunggu',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: isUpdating
                                        ? null
                                        : markNextAsDone,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: isUpdating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Selesai'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Urutan antrian aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...queueList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isFirst = index == 0;
                              final queueNumber = index + 1;
                              final storedQueueNumber = _queueNumberOf(item);
                              final customerName = _customerNameOf(item);
                              final date = _dateOf(item);
                              final time = _timeOf(item);
                              final status = _statusOf(item);
                              final bookingId = _valueOf(item, [
                                'id',
                                'booking_id',
                                'bookingId',
                              ]);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isFirst
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                    width: isFirst ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: isFirst
                                              ? Colors.green
                                              : Colors.black,
                                          child: Text(
                                            queueNumber.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customerName.isEmpty
                                                    ? 'Pelanggan ${index + 1}'
                                                    : customerName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tanggal: ${date.isEmpty ? '-' : date} | Jam: ${time.isEmpty ? '-' : time}',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Nomor lama: $storedQueueNumber',
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (bookingId.isNotEmpty)
                                                Text(
                                                  'Booking ID: $bookingId',
                                                  style: const TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isFirst
                                                ? Colors.green.shade50
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            isFirst
                                                ? 'Sedang Dilayani'
                                                : status,
                                            style: TextStyle(
                                              color: isFirst
                                                  ? Colors.green.shade800
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isFirst) ...[
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Catatan: data paling atas adalah pelanggan yang sedang dikerjakan. Saat tombol Selesai ditekan, antrian berikutnya otomatis naik.',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
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
}
