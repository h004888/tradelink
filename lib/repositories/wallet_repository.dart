import '../core/api_client.dart';
import '../core/result.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final _api = ApiClient.instance;

  Future<Result<Wallet>> getWallet() async {
    final res = await _api.get('/wallet');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Wallet>(Wallet.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Wallet>(f),
    };
  }

  Future<Result<List<WalletLedgerEntry>>> getLedger({int page = 1, int limit = 20}) async {
    final res = await _api.get('/wallet/ledger', query: {'page': page.toString(), 'limit': limit.toString()});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<WalletLedgerEntry>>(
          ((d['data'] as List?) ?? []).map((e) => WalletLedgerEntry.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<WalletLedgerEntry>>(f),
    };
  }

  Future<Result<List<WithdrawalRequestItem>>> getMyWithdrawals() async {
    final res = await _api.get('/wallet/withdrawals');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<WithdrawalRequestItem>>(
          ((d['data'] as List?) ?? []).map((e) => WithdrawalRequestItem.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<WithdrawalRequestItem>>(f),
    };
  }

  Future<Result<WithdrawalRequestItem>> requestWithdrawal({
    required double amount,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
  }) async {
    final res = await _api.post('/wallet/withdrawals', body: {
      'amount': amount,
      'bankName': ?bankName,
      'bankAccountNumber': ?bankAccountNumber,
      'bankAccountHolder': ?bankAccountHolder,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<WithdrawalRequestItem>(
          WithdrawalRequestItem.fromJson(d['data'] as Map<String, dynamic>),
        ),
      FailureResult(failure: final f) => FailureResult<WithdrawalRequestItem>(f),
    };
  }
}
