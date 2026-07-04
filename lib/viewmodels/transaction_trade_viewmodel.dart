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

  Future<void> load() async {
    _state = const Loading(); notifyListeners();
    final r = await _repo.getById(transactionId);
    switch (r) { case ResultSuccess(data: final t): _state = Success(t); case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true); }
    notifyListeners();
  }
}
