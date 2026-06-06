import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'status_screen.dart';
import 'booking_screen.dart'; 

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. KUNCI PERTAMA: List dipindahkan ke dalam build agar bisa mengakses fungsi _onItemTapped
    // 2. KUNCI KEDUA: Kata kunci 'const' dihapus dari HomeScreen, BookingScreen, dan StatusScreen
    final List<Widget> screens = [
      HomeScreen(
        onChangeTab: (index) => _onItemTapped(index), // Jalur kabel terpasang!
      ),
      BookingScreen(), 
      StatusScreen(),                                                                                                                                                                          
      const Center(child: Text('Akun Screen (Belum Diimport)', style: TextStyle(color: Colors.white))),    
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141414), 
      body: screens[_selectedIndex], // Menggunakan variabel screens lokal yang baru
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- BAGIAN NAV BAR (Tetap mempertahankan fitur label sembunyi milik Anda) ---
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF141414),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      
      showSelectedLabels: true,      // Menampilkan teks saat item diklik (aktif)
      showUnselectedLabels: false,   // Menyembunyikan teks saat item tidak aktif
      
      selectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'InriaSerif'),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'InriaSerif'),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          activeIcon: Icon(Icons.access_time_filled),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Akun',
        ),
      ],
    );
  }
}