import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/barbershop_api";
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "http://10.0.2.2/barbershop_api";
      default:
        return "http://localhost/barbershop_api";
    }
  }
}
