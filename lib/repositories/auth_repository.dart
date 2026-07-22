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
}
