import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../services/chat_socket.dart';

class AuthRepository {
  final _api = ApiClient.instance;

  /// Lấy thông tin user hiện tại từ access token đang lưu local.
  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    final res = await _api.get('/auth/me');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(
        (d['data'] as Map?)?.cast<String, dynamic>() ?? d,
      ),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  Future<Result<Map<String, dynamic>>> register(
    String email,
    String password,
    String name, {
    String? phone,
    String? address,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': name,
      'phone': phone,
    };
    if (address != null && address.isNotEmpty) body['address'] = address;

    final res = await _api.post('/auth/register', body: body);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(
        d['data'] ?? {},
      ),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  Future<Result<bool>> loginWithPassword(String email, String password) async {
    final res = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return _setTokenFromResult(res);
  }

  Future<Result<bool>> loginWithGoogle(String idToken) async {
    final res = await _api.post('/auth/google', body: {'idToken': idToken});
    return _setTokenFromResult(res);
  }

  Future<Result<bool>> _setTokenFromResult(
    Result<Map<String, dynamic>> res,
  ) async {
    if (res is ResultSuccess<Map<String, dynamic>>) {
      final data = res.data['data'] as Map;
      await _api.setToken(data['token'] as String);
      if (data['refreshToken'] != null) {
        await _api.setRefreshToken(data['refreshToken'] as String);
      }
      if (data['userId'] != null) {
        await _api.setUserId(data['userId'] as String);
      } else if (data['user'] is Map) {
        final userId =
            (data['user'] as Map)['_id'] as String? ??
            (data['user'] as Map)['id'] as String?;
        if (userId != null) await _api.setUserId(userId);
      }
      if (data['user'] is Map) {
        final role = (data['user'] as Map)['role'] as String?;
        if (role != null) await _api.setRole(role);
      }
      return ResultSuccess<bool>(true);
    }
    return FailureResult<bool>(
      (res as FailureResult<Map<String, dynamic>>).failure,
    );
  }
}
