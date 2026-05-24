import 'package:flutter/material.dart';
import '../screens/login_screen.dart'; // Pastikan membuat file ini
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/status_screen.dart';
import '../screens/main_navigation.dart'; // Impor main_navigation
import '../screens/admin_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String mainNav = '/main_nav';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String status = '/status';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      admin:(context) => const AdminScreen(),
      mainNav: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      booking: (context) => const BookingScreen(),
      status: (context) => const StatusScreen(),
    };
  }
}