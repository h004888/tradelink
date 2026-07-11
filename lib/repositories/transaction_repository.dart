import '../core/api_client.dart';
import '../core/result.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _api = ApiClient.instance;

  Transaction _fromJson(Map<String, dynamic> j) => Transaction(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        type: j['type'] == 'trade' ? TransactionType.trade : TransactionType.sale,
        listingId: j['listingId']?.toString() ?? '',
        listingTitle: j['listingTitle'] as String? ?? '',
        buyerId: j['buyerId']?.toString() ?? '',
        buyerName: j['buyerName'] as String? ?? '',
        sellerId: j['sellerId']?.toString() ?? '',
        sellerName: j['sellerName'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble(),
        escrowStep: _parseEscrowStep(j['escrowStep'] as String?),
        partyASent: j['partyASent'] as bool?,
        partyAReceived: j['partyAReceived'] as bool?,
        partyBSent: j['partyBSent'] as bool?,
        partyBReceived: j['partyBReceived'] as bool?,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Future<Result<Transaction>> getById(String id) async {
    final res = await _api.get('/transactions/$id');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Transaction>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Transaction>(f),
    };
  }

  Future<Result<Transaction>> create(String listingId, {double? amount}) async {
    final res = await _api.post('/transactions', body: {'listingId': listingId, 'amount': amount});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Transaction>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Transaction>(f),
    };
  }

  Future<Result<List<Transaction>>> getAll({String? role}) async {
    final res = await _api.get('/transactions', query: role != null ? {'role': role} : null);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Transaction>>(
          ((d['data'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Transaction>>(f),
    };
  }

  Future<Result<Transaction>> advanceEscrow(String id) async {
    final res = await _api.post('/transactions/$id/advance-escrow');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Transaction>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Transaction>(f),
    };
  }

  Future<Result<Transaction>> confirmTrade(String id, String party, bool sent, bool received) async {
    final res = await _api.post('/transactions/$id/confirm', body: {'party': party, 'sent': sent, 'received': received});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Transaction>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Transaction>(f),
    };
  }
}

EscrowStep? _parseEscrowStep(String? s) {
  if (s == null) return null;
  for (final v in EscrowStep.values) {
    if (v.name == s) return v;
  }
  return null;
}
