import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class TransactionListViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  String _role = 'buyer';
  String get role => _role;

  UiState<List<Transaction>> _state = const Loading();
  UiState<List<Transaction>> get state => _state;

  TransactionListViewModel({String? initialRole}) {
    load();
  }

  /// Load tất cả giao dịch (không filter role) cho tab tổng quan
  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final r = await _repo.getAll();
    if (r is ResultSuccess<List<Transaction>>) {
      _state = Success(r.data);
    } else if (r is FailureResult<List<Transaction>>) {
      _state = Error(message: r.failure.message, retryable: true);
    }
    notifyListeners();
  }

  void setRole(String newRole) {
    if (_role == newRole) return;
    _role = newRole;
    load();
  }
}
