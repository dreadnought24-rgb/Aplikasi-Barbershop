import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/barbershop_api";//?
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "http://192.168.1.39/barbershop_api";
      default:
        return "http://192.168.1.39/barbershop_api";
    }
  }
}
