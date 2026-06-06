import 'package:flutter/material.dart';
import '../screens/login_screen.dart'; // Pastikan membuat file ini
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/status_screen.dart';
import '../screens/main_navigation.dart'; // Impor main_navigation
import '../screens/admin_screen.dart';
import '../widgets/splashlogo.dart'; // Impor SplashLogo

class AppRoutes {
  static const String login = '/login';
  static const String mainNav = '/main_nav';
  static const String home = '/home' ;
  static const String booking = '/booking';
  static const String status = '/status';
  static const String admin = '/admin';
  static const String splash = '/splash';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      splash: (context) => const SplashLogo(),
      admin: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final adminUserId = args is int ? args : 0;
        return AdminScreen(adminUserId: adminUserId);
      },
      mainNav: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      booking: (context) => const BookingScreen(),
      status: (context) => const StatusScreen(),
    };
  }
}
