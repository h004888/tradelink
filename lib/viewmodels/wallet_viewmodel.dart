import 'package:flutter/material.dart';
import '../core/result.dart';
import '../core/ui_state.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repository = WalletRepository();

  UiState<Wallet> _walletState = const Loading();
  UiState<Wallet> get walletState => _walletState;

  UiState<List<WalletLedgerEntry>> _ledgerState = const Loading();
  UiState<List<WalletLedgerEntry>> get ledgerState => _ledgerState;

  UiState<List<WithdrawalRequestItem>> _withdrawalsState = const Loading();
  UiState<List<WithdrawalRequestItem>> get withdrawalsState => _withdrawalsState;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  WalletViewModel() {
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadWallet(), loadLedger(), loadWithdrawals()]);
  }

  Future<void> loadWallet() async {
    _walletState = const Loading();
    notifyListeners();
    final res = await _repository.getWallet();
    switch (res) {
      case ResultSuccess<Wallet>(:final data):
        _walletState = Success(data);
      case FailureResult<Wallet>(:final failure):
        _walletState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> loadLedger() async {
    _ledgerState = const Loading();
    notifyListeners();
    final res = await _repository.getLedger();
    switch (res) {
      case ResultSuccess<List<WalletLedgerEntry>>(:final data):
        _ledgerState = Success(data);
      case FailureResult<List<WalletLedgerEntry>>(:final failure):
        _ledgerState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> loadWithdrawals() async {
    _withdrawalsState = const Loading();
    notifyListeners();
    final res = await _repository.getMyWithdrawals();
    switch (res) {
      case ResultSuccess<List<WithdrawalRequestItem>>(:final data):
        _withdrawalsState = Success(data);
      case FailureResult<List<WithdrawalRequestItem>>(:final failure):
        _withdrawalsState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  /// Trả về null nếu thành công, hoặc message lỗi để hiển thị.
  Future<String?> submitWithdrawal({
    required double amount,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    final res = await _repository.requestWithdrawal(
      amount: amount,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountHolder: bankAccountHolder,
    );
    _isSubmitting = false;
    notifyListeners();
    if (res is ResultSuccess<WithdrawalRequestItem>) {
      await loadAll();
      return null;
    }
    return (res as FailureResult<WithdrawalRequestItem>).failure.message;
  }
}
