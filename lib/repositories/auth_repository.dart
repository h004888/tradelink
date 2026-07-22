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
}
