import '../core/api_client.dart';
import '../core/result.dart';
import '../models/dispute_model.dart';

class DisputeRepository {
  final _api = ApiClient.instance;

  /// GET /disputes/:transactionId — Lấy khiếu nại của 1 giao dịch (404 nếu chưa có).
  Future<Result<Dispute>> getByTransaction(String transactionId) async {
    final res = await _api.get('/disputes/$transactionId');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Dispute>(Dispute.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Dispute>(f),
    };
  }

  /// POST /disputes — Tạo khiếu nại mới.
  Future<Result<Dispute>> createDispute({
    required String transactionId,
    required String reason,
    required String description,
    bool priority = false,
  }) async {
    final res = await _api.post('/disputes', body: {
      'transactionId': transactionId,
      'reason': reason,
      'description': description,
      'priority': priority,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Dispute>(Dispute.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Dispute>(f),
    };
  }
}
