import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/status_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String booking = '/booking';
  static const String status = '/status';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      booking: (context) => const BookingScreen(),
      status: (context) => const StatusScreen(),
    };
  }
}