import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Override at build time, for example: --dart-define=API_URL=http://192.168.1.10:3000.
abstract final class ApiConfig {
  static const _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }
}
