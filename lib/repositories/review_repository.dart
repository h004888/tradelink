import '../core/api_client.dart';
import '../core/result.dart';

class ReviewRepository {
  final _api = ApiClient.instance;

  /// POST /reviews — submit review sau khi giao dịch hoàn tất.
  /// Backend tự xác định reviewerId từ token và cập nhật reputation score của target.
  Future<Result<bool>> submitReview({
    required String transactionId,
    required String targetId,
    required int rating,
    required int communication,
    required int punctuality,
    required int quality,
    String? comment,
  }) async {
    final res = await _api.post('/reviews', body: {
      'transactionId': transactionId,
      'targetId': targetId,
      'rating': rating,
      'communication': communication,
      'punctuality': punctuality,
      'quality': quality,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// GET /reviews/user/:userId — public reviews của 1 user.
  Future<Result<List<Map<String, dynamic>>>> getByUser(String userId) async {
    final res = await _api.get('/reviews/user/$userId');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Map<String, dynamic>>>(
          ((d['data'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Map<String, dynamic>>>(f),
    };
  }
}
