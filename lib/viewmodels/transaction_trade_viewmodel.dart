import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class TransactionTradeViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final String transactionId;

  UiState<Transaction> _state = const Loading();
  UiState<Transaction> get state => _state;

  TransactionTradeViewModel({required this.transactionId}) { load(); }

  // D5 — view trade
  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final r = await _repo.getById(transactionId);
    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
    } else if (r is FailureResult<Transaction>) {
      _state = Error(message: r.failure.message, retryable: true);
    }
    notifyListeners();
  }

  // D6 — confirm trade (party sent/received)
  Future<bool> confirmTrade(String party, bool sent, bool received) async {
    final r = await _repo.confirmTrade(transactionId, party, sent, received);
    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
      notifyListeners();
      return true;
    }
    if (r is FailureResult<Transaction>) {
      _state = Error(message: r.failure.message, retryable: true);
    } else {
      _state = Error(message: 'Lỗi không xác định');
    }
    notifyListeners();
    return false;
  }
}
