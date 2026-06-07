import 'package:flutter/material.dart';
import '../widgets/base_background.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onChangeTab;
  final String username; // ← terima username dari luar

  const HomeScreen({
    super.key,
    this.onChangeTab,
    this.username = 'User', // default jika belum login
  });

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: LOGO DAN NOTIFIKASI ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets//images/barberinLogo.png',
                      height: 35,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
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
                  username.toUpperCase(), // ← pakai username dari DB
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 35),

                // --- SUBHEADER: FEATURED SERVICES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'InriaSerif',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                      onPressed: () {
                        if (onChangeTab != null) onChangeTab!(1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- HORIZONTAL SERVICES SLIDER ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildServiceCard(
                        imagePath: 'assets/images/classic_cut.jpg',
                        tag: 'MOST POPULAR',
                        title: 'Classic Cut (Adult)',
                        duration: '45 Mins',
                        price: 'Rp 40.000',
                        onTap: () { if (onChangeTab != null) onChangeTab!(1); },
                      ),
                      const SizedBox(width: 15),
                      _buildServiceCard(
                        imagePath: 'assets/images/junior_cut.jpg',
                        tag: 'YOUNG',
                        title: 'Junior Cut',
                        duration: '40 Mins',
                        price: 'Rp 45.000',
                        onTap: () { if (onChangeTab != null) onChangeTab!(1); },
                      ),
                      const SizedBox(width: 15),
                      _buildServiceCard(
                        imagePath: 'assets/images/executive_cut.jpg',
                        tag: 'PERFECT',
                        title: 'Executive Cut',
                        duration: '50 Mins',
                        price: 'Rp 50.000',
                        onTap: () { if (onChangeTab != null) onChangeTab!(1); },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- LIVE STATUS BANNER ---
                InkWell(
                  onTap: () { if (onChangeTab != null) onChangeTab!(2); },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white10,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2B2B2B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.hourglass_empty, color: Colors.white70),
                            ),
                            Positioned(
                              left: 0,
                              child: Container(width: 4, height: 20, color: Colors.red),
                            )
                          ],
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '15 Menit lagi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontFamily: 'InriaSerif',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      children: [
                                        CircleAvatar(radius: 3, backgroundColor: Colors.red),
                                        SizedBox(width: 4),
                                        Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '2 pelanggan sedang dalam antrian',
                                style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'InriaSerif'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B2B2B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        )
                      ],
                    ),
                  ),
                )
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif')),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(duration, style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'InriaSerif')),
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'InriaSerif')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}