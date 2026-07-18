import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../services/chat_socket.dart';

class AuthRepository {
  final _api = ApiClient.instance;

  Future<Result<Map<String, dynamic>>> register(String email, String password, String name, {String? phone, String? address}) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };
    if (address != null && address.isNotEmpty) body['address'] = address;

    final res = await _api.post('/auth/register', body: body);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(d['data'] ?? {}),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  Future<Result<bool>> loginWithPassword(String email, String password) async {
    final res = await _api.post('/auth/login', body: {'email': email, 'password': password});
    return _setTokenFromResult(res);
  }

  /// Khi token hết hạn, client gọi endpoint /refresh với refreshToken để lấy token mới.
  /// Backend thực hiện refresh token rotation: token cũ bị vô hiệu, cấp cả access + refresh mới.
  Future<Result<bool>> refreshToken() async {
    final oldRefreshToken = _api.getRefreshToken();
    if (oldRefreshToken == null) {
      return FailureResult(AuthFailure(message: 'Không có refresh token'));
    }
    final res = await _api.post('/auth/refresh', body: {'refreshToken': oldRefreshToken});
    if (res is FailureResult<Map<String, dynamic>>) {
      // Refresh failed → clear tokens
      await _api.clearTokens();
      return FailureResult<bool>((res).failure);
    }
    final s = res as ResultSuccess<Map<String, dynamic>>;
    final data = s.data['data'] as Map;
    final newToken = data['token'] as String;
    final newRefreshToken = data['refreshToken'] as String?;
    await _api.setToken(newToken);
    if (newRefreshToken != null) {
      await _api.setRefreshToken(newRefreshToken);
    }
    return ResultSuccess<bool>(true);
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
    await _api.clearTokens();
    // Dispose chat socket để ngắt kết nối realtime với token cũ,
    // đảm bảo user mới login sẽ reconnect với token mới.
    ChatSocket.instance.dispose();
  }

  /// Đổi mật khẩu — backend yêu cầu Bearer token, verify mật khẩu cũ và hash mật khẩu mới.
  Future<Result<bool>> changePassword(String oldPassword, String newPassword) async {
    final res = await _api.post('/auth/change-password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// A2 — yêu cầu reset password, trả token (workaround vì chưa có email service)
  Future<Result<String>> forgotPassword(String email) async {
    final res = await _api.post('/auth/forgot-password', body: {'email': email});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<String>(
          ((d['data'] as Map?)?['token'] as String?) ?? '',
        ),
      FailureResult(failure: final f) => FailureResult<String>(f),
    };
  }

  /// A2 — đặt lại mật khẩu bằng token.
  Future<Result<bool>> resetPassword(String token, String newPassword) async {
    final res = await _api.post('/auth/reset-password', body: {
      'token': token,
      'newPassword': newPassword,
    });
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// A3 — xác nhận email bằng token.
  Future<Result<bool>> verifyEmail(String token) async {
    final res = await _api.post('/auth/verify-email', body: {'token': token});
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// Verify OTP
  Future<Result<Map<String, dynamic>>> verifyOTP(String email, String otp) async {
    final res = await _api.post('/auth/verify-otp', body: {'email': email, 'otp': otp});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(d['data']),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  /// Resend OTP
  Future<Result<bool>> resendOTP(String email) async {
    final res = await _api.post('/auth/resend-otp', body: {'email': email});
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  Future<Result<bool>> _setTokenFromResult(Result<Map<String, dynamic>> res) async {
    if (res is ResultSuccess<Map<String, dynamic>>) {
      final data = res.data['data'] as Map;
      await _api.setToken(data['token'] as String);
      if (data['refreshToken'] != null) {
        await _api.setRefreshToken(data['refreshToken'] as String);
      }
      if (data['userId'] != null) {
        await _api.setUserId(data['userId'] as String);
      } else if (data['user'] is Map) {
        final userId = (data['user'] as Map)['_id'] as String? ?? (data['user'] as Map)['id'] as String?;
        if (userId != null) await _api.setUserId(userId);
      }
      return ResultSuccess<bool>(true);
    }
    return FailureResult<bool>((res as FailureResult<Map<String, dynamic>>).failure);
  }
}
