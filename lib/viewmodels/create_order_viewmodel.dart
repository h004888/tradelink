import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class CreateOrderViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  final String listingId;
  UiState<Transaction> _state = const Idle();
  UiState<Transaction> get state => _state;
  bool _agreed = false;
  bool get agreed => _agreed;

  CreateOrderViewModel({required this.listingId});

  void toggleAgree(bool? v) {
    _agreed = v ?? false;
    notifyListeners();
  }

  /// D1 — Create transaction (Mua hàng)
  Future<Transaction?> confirm() async {
    if (!_agreed) {
      _state = Error(message: 'Vui lòng đồng ý điều khoản');
      notifyListeners();
      return null;
    }
    _state = const Loading();
    notifyListeners();
    final result = await _repository.create(listingId);
    if (result is ResultSuccess<Transaction>) {
      _state = Success(result.data);
      notifyListeners();
      return result.data;
    }
    if (result is FailureResult<Transaction>) {
      _state = Error(message: result.failure.message, retryable: true);
    } else {
      _state = Error(message: 'Lỗi không xác định');
    }
    notifyListeners();
    return null;
  }
}
