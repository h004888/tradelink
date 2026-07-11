import 'package:flutter/material.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/dispute_model.dart';
import '../../repositories/dispute_repository.dart';

class DisputeViewModel extends ChangeNotifier {
  final DisputeRepository _repository = DisputeRepository();
  final String transactionId;

  UiState<Dispute?> _state = const Idle();
  UiState<Dispute?> get state => _state;

  Dispute? _existing;
  Dispute? get existingDispute => _existing;

  String _reason = '';
  String get reason => _reason;
  String _description = '';
  String get description => _description;
  bool _priority = false;
  bool get priority => _priority;

  DisputeViewModel({required this.transactionId}) {
    loadExisting();
  }

  /// Tải khiếu nại đã tồn tại (nếu có) — dùng G2 "Get dispute by transaction".
  Future<void> loadExisting() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getByTransaction(transactionId);
    switch (res) {
      case ResultSuccess<Dispute>():
        _existing = res.data;
        _state = Success(res.data);
      case FailureResult<Dispute>(:final failure):
        // 404 = chưa có khiếu nại — đó là state bình thường, hiển thị form tạo
        if (failure is NotFoundFailure) {
          _existing = null;
          _state = const Success(null);
        } else {
          _state = Error(message: failure.message, retryable: true);
        }
    }
    notifyListeners();
  }

  void setReason(String v) { _reason = v; notifyListeners(); }
  void setDescription(String v) { _description = v; notifyListeners(); }
  void setPriority(bool v) { _priority = v; notifyListeners(); }

  /// Gửi khiếu nại mới — backend đã có validate và tạo notification cho bên kia + admin.
  Future<bool> submit() async {
    if (_reason.isEmpty || _description.isEmpty) {
      _state = const Error(message: 'Vui lòng chọn lý do và mô tả chi tiết', retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();
    final res = await _repository.createDispute(
      transactionId: transactionId,
      reason: _reason,
      description: _description,
      priority: _priority,
    );
    switch (res) {
      case ResultSuccess<Dispute>():
        _existing = res.data;
        _state = Success(res.data);
        notifyListeners();
        return true;
      case FailureResult<Dispute>(:final failure):
        _state = Error(message: failure.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
