/// Template cấu hình IP backend cho TradeLink.
///
/// ## Cách dùng
/// 1. Copy file này thành `env.dart` trong cùng thư mục
/// 2. Sửa `baseUrl` thành IP máy tính đang chạy backend server
/// 3. `flutter run` (hoặc hot restart nếu đang chạy)
///
/// ## IP backend theo môi trường
/// | Môi trường              | IP mặc định                          |
/// |-------------------------|--------------------------------------|
/// | Android Emulator (AVD)  | http://10.0.2.2:3000/api/v1           |
/// | Physical device (USB)   | http://IP-LAN-cua-may:3000/api/v1    |
/// | Physical device (WiFi)  | http://IP-LAN-cua-may:3000/api/v1    |
/// | Web / Desktop           | http://localhost:3000/api/v1          |
///
/// ## Tìm IP LAN của máy
/// - Windows: mở CMD → `ipconfig` → tìm "IPv4 Address"
/// - macOS:   mở Terminal → `ifconfig en0` → tìm "inet"
/// - Linux:   mở Terminal → `hostname -I`
class Env {
  Env._();

  /// Base URL của backend server.
  /// Để trống để dùng auto-detect (localhost / 10.0.2.2).
  ///
  /// Ví dụ:
  ///   static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
  static const String baseUrl = '';
}
