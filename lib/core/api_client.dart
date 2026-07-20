import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import '../services/storage_service.dart';
import 'failure.dart';
import 'result.dart';

/// Base URL cho backend — resolve từ AppConfig.
/// Xem [AppConfig.baseUrl] để biết chi tiết resolution priority.
String get baseUrl => AppConfig.baseUrl;
Duration get _timeout => AppConfig.timeout;

typedef RefreshTokenCallback = Future<bool> Function();

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;
  String? _refreshToken;
  String? _userId;
  String? _role;
  RefreshTokenCallback? _onRefresh;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Khôi phục token từ persistent storage khi app khởi động.
  /// Gọi 1 lần duy nhất, ngay sau khi FlutterBinding initialized.
  Future<void> init() async {
    if (_initialized) return;
    _token = await StorageService.instance.getToken();
    _refreshToken = await StorageService.instance.getRefreshToken();
    _role = await StorageService.instance.getRole();
    _userId = await StorageService.instance.getUserId();
    _initialized = true;
  }

  /// Inject callback từ AuthRepository để auto-refresh khi 401
  void registerRefreshCallback(RefreshTokenCallback cb) {
    _onRefresh = cb;
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await StorageService.instance.saveToken(token);
    } else {
      await StorageService.instance.clearTokens();
    }
  }

  Future<void> setRefreshToken(String? t) async {
    _refreshToken = t;
    if (t != null) {
      await StorageService.instance.saveRefreshToken(t);
    }
  }

  String? getToken() => _token;
  String? getRefreshToken() => _refreshToken;
  String? getUserId() => _userId;

  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (userId != null) {
      await StorageService.instance.saveUserId(userId);
    } else {
      await StorageService.instance.clearUserId();
    }
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    _role = null;
    await StorageService.instance.clearTokens();
  }

  /// Role hiện tại — cache trong bộ nhớ, đọc được ngay lập tức (không async) để
  /// router có thể quyết định redirect admin/user mà không cần chờ gọi API.
  String? getRole() => _role;

  Future<void> setRole(String? role) async {
    _role = role;
    if (role != null) {
      await StorageService.instance.saveRole(role);
    }
  }

  Map<String, String> _headers() {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Future<Result<Map<String, dynamic>>> _exec(Future<http.Response> Function() req) async {
    try {
      var res = await req().timeout(_timeout);
      // Auto-refresh on 401 (token expired)
      if (res.statusCode == 401 && _onRefresh != null && _refreshToken != null) {
        final ok = await _onRefresh!();
        if (ok) {
          res = await req().timeout(_timeout);
        }
      }
      return _parse(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  Future<Result<Map<String, dynamic>>> get(String path, {Map<String, String>? query}) async {
    return _exec(() async {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      return http.get(uri, headers: _headers());
    });
  }

  Future<Result<Map<String, dynamic>>> post(String path, {Object? body}) async {
    return _exec(() async {
      final uri = Uri.parse('$baseUrl$path');
      return http.post(uri, headers: _headers(), body: body == null ? null : jsonEncode(body));
    });
  }

  Future<Result<Map<String, dynamic>>> put(String path, {Object? body}) async {
    return _exec(() async {
      final uri = Uri.parse('$baseUrl$path');
      return http.put(uri, headers: _headers(), body: body == null ? null : jsonEncode(body));
    });
  }

  Future<Result<Map<String, dynamic>>> patch(String path, {Object? body}) async {
    return _exec(() async {
      final uri = Uri.parse('$baseUrl$path');
      return http.patch(uri, headers: _headers(), body: body == null ? null : jsonEncode(body));
    });
  }

  Future<Result<Map<String, dynamic>>> delete(String path) async {
    return _exec(() async {
      final uri = Uri.parse('$baseUrl$path');
      return http.delete(uri, headers: _headers());
    });
  }

  Result<Map<String, dynamic>> _parse(http.Response res) {
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return FailureResult(NetworkFailure(message: 'Response không hợp lệ', statusCode: res.statusCode));
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ResultSuccess(decoded);
    }

    final msg = decoded['message'] as String? ?? 'Lỗi không xác định';
    if (res.statusCode == 401 || res.statusCode == 403) {
      return FailureResult(AuthFailure(message: msg));
    }
    if (res.statusCode == 404) {
      return FailureResult(ServerFailure(message: msg, statusCode: res.statusCode));
    }
    if (res.statusCode >= 500) {
      return FailureResult(ServerFailure(message: msg, statusCode: res.statusCode));
    }
    if (res.statusCode == 400 || res.statusCode == 409) {
      return FailureResult(ValidationFailure(message: msg));
    }
    return FailureResult(NetworkFailure(message: msg, statusCode: res.statusCode));
  }

  Result<Map<String, dynamic>> _mapError(Object e) {
    if (e.toString().contains('TimeoutException')) {
      return const FailureResult(NetworkFailure(message: 'Yêu cầu hết thời gian. Kiểm tra kết nối.'));
    }
    return FailureResult(NetworkFailure(message: 'Không kết nối được server: $e'));
  }
}
