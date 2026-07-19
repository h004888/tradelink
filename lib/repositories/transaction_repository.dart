import '../core/api_client.dart';
import '../core/result.dart';
import '../models/transaction_model.dart';

class PaymentInfo {
  final String qrUrl;
  final String paymentCode;
  final double amount;
  final String bankAccountNumber;
  final String bankAccountName;

  const PaymentInfo({
    required this.qrUrl,
    required this.paymentCode,
    required this.amount,
    required this.bankAccountNumber,
    required this.bankAccountName,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> j) => PaymentInfo(
        qrUrl: j['qrUrl']?.toString() ?? '',
        paymentCode: j['paymentCode']?.toString() ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        bankAccountNumber: j['bankAccountNumber']?.toString() ?? '',
        bankAccountName: j['bankAccountName']?.toString() ?? '',
      );
}

class TransactionRepository {
  final _api = ApiClient.instance;

  Transaction _fromJson(Map<String, dynamic> j) => Transaction.fromJson(j);

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

  Future<Result<PaymentInfo>> getPaymentInfo(String id) async {
    final res = await _api.get('/transactions/$id/payment-info');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<PaymentInfo>(PaymentInfo.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<PaymentInfo>(f),
    };
  }
}
