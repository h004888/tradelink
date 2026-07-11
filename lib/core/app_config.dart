import 'dart:io' show Platform;

import 'env.dart';

/// Cấu hình ứng dụng TradeLink.
///
/// ## API Base URL resolution priority:
/// 1. `--dart-define=API_BASE_URL=...` (build-time, ưu tiên cao nhất)
/// 2. Platform auto-detection (mặc định)
///
/// ## Platform defaults:
/// | Platform | Default URL | Ghi chú |
/// |----------|------------|---------|
/// | Android emulator (AVD) | `http://10.0.2.2:3000/api/v1` | 10.0.2.2 = host machine |
/// | Web | `http://localhost:3000/api/v1` | Chạy trên browser |
/// | iOS simulator | `http://localhost:3000/api/v1` | |
/// | Physical device / LDPlayer | `http://192.168.0.102:3000/api/v1` | Cần match host LAN IP |
/// | Desktop (Windows/macOS/Linux) | `http://localhost:3000/api/v1` | |
class AppConfig {
  AppConfig._();

  /// Thời gian timeout mặc định cho API requests.
  static const Duration apiTimeout = Duration(seconds: 15);

  /// Environmental variable keys (dart-define).
  static const String _envKeyBaseUrl = 'API_BASE_URL';
  static const String _envKeyApiTimeout = 'API_TIMEOUT_SECONDS';

  /// --- Ngưỡng timeout (có thể override qua dart-define) ---
  static Duration get timeout {
    final raw = const String.fromEnvironment(_envKeyApiTimeout);
    if (raw.isNotEmpty) {
      final seconds = int.tryParse(raw);
      if (seconds != null && seconds > 0) {
        return Duration(seconds: seconds);
      }
    }
    return apiTimeout;
  }

  /// --- API Base URL ---
  ///
  /// Ưu tiên: Env.baseUrl → dart-define → platform auto-detect → fallback
  static String get baseUrl {
    // 1. env.dart (developer local config — highest priority)
    if (Env.baseUrl.isNotEmpty) return Env.baseUrl;

    // 2. dart-define override (build-time config)
    final envUrl = const String.fromEnvironment(_envKeyBaseUrl);
    if (envUrl.isNotEmpty) return envUrl;

    // 3. Platform auto-detection
    return _detectPlatformUrl();
  }

  /// Auto-detect platform và trả về URL phù hợp.
  static String _detectPlatformUrl() {
    try {
      if (Platform.isAndroid) {
        // Android emulator: dùng localhost + adb reverse để bypass firewall
        return 'http://localhost:3000/api/v1';
      }
      if (Platform.isIOS) {
        // iOS simulator dùng localhost
        return 'http://localhost:3000/api/v1';
      }
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop app (native)
        return 'http://localhost:3000/api/v1';
      }
    } catch (_) {
      // Platform not available (e.g., web) hoặc lỗi khác
    }

    // Web fallback — dùng cùng host/port với trang web
    // Trong development: http://localhost:3000
    // Trong production: relative path hoặc URL config
    return 'http://localhost:3000/api/v1';
  }
}
