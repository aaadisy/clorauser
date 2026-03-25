import 'package:flutter/foundation.dart';

class AppServerConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://apis.getclora.com';
    } else if (kProfileMode) {
      return 'https://apis.getclora.com';
    } else {
      return 'https://apis.getclora.com';
    }
  }
}
