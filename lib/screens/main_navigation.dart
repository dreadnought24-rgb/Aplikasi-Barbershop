import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'status_screen.dart';
import 'booking_screen.dart';
import 'profile_screen.dart';
import '../services/profile_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _username = 'User';
  String? _pendingService; // layanan yang akan di-pre-seleksi di BookingScreen

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final profile = await ProfileService().loadUserData();
    if (!mounted) return;
    setState(() => _username = profile.username);
  }

  /// Pindah tab, opsional bawa nama layanan untuk pre-seleksi di BookingScreen
  void _onItemTapped(int index, {String? service}) {
    setState(() {
      _selectedIndex = index;
      if (index == 1 && service != null && service.trim().isNotEmpty) {
        _pendingService = service;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onChangeTab: _onItemTapped,
        username: _username,
      ),
      BookingScreen(
        initialService: _pendingService,
      ),
      StatusScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => _onItemTapped(i),
      ),
    );
  }
}

// --- BAGIAN NAV BAR ---
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
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'InriaSerif'),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'InriaSerif'),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), activeIcon: Icon(Icons.access_time_filled), label: 'Status'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Akun'),
      ],
    );
  }
}
