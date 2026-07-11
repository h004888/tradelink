import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class TransactionSaleViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final String transactionId;

  UiState<Transaction> _state = const Loading();
  UiState<Transaction> get state => _state;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  TransactionSaleViewModel({required this.transactionId}) { load(); }

  // D2/D3 — view buyer/seller
  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final meR = await ApiClient.instance.get('/auth/me');
    if (meR is ResultSuccess<Map<String, dynamic>>) {
      _currentUserId = ((meR.data['data'] as Map)['_id'] ?? '').toString();
    }
    final r = await _repo.getById(transactionId);
    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
    } else if (r is FailureResult<Transaction>) {
      _state = Error(message: r.failure.message, retryable: true);
    }
    notifyListeners();
  }

  /// Trả về userId của người được đánh giá (bên kia của transaction).
  String? targetId() {
    final s = _state;
    if (s is! Success<Transaction>) return null;
    if (_currentUserId == null) return null;
    final tx = s.data;
    return _currentUserId == tx.buyerId ? tx.sellerId : tx.buyerId;
  }

  bool isBuyer() {
    final s = _state;
    if (s is! Success<Transaction>) return false;
    return _currentUserId == s.data.buyerId;
  }

  // D4 — advance escrow
  Future<bool> advanceEscrow() async {
    if (_state is! Success<Transaction>) return false;
    final r = await _repo.advanceEscrow(transactionId);
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
