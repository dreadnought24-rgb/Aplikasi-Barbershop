import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../utils/session_helper.dart';
import '../screens/main_navigation.dart';
import '../screens/admin_screen.dart';
import 'base_background.dart'; 

class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () async {
      final isLogin = await SessionHelper.isLogin();

      if (!mounted) return;

      if (isLogin) {
        final role = await SessionHelper.getRole();
        final userId = await SessionHelper.getUserId();

        if (!mounted) return;

        if (role == 'admin' && userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminScreen(adminUserId: userId),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainNavigation(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan BaseBackground sebagai pembungkus utama menggantikan Scaffold bawaan
    return BaseBackground(
      child: Center(
        child: Image.asset(
          'assets/images/barberinLogo.png',
          width: 180,
        ),
      ),
    );
  }
}