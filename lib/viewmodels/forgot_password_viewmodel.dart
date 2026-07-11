import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UiState<String> _state = const Idle();
  UiState<String> get state => _state;

  /// Token reset (returned từ backend khi email service chưa có).
  String? get resetToken => _state is Success<String> ? (_state as Success<String>).data : null;

  String _email = '';
  String get email => _email;

  void setEmail(String v) { _email = v.trim(); notifyListeners(); }

  Future<bool> submit() async {
    if (_email.isEmpty) {
      _state = Error(message: 'Vui lòng nhập email', retryable: false);
      notifyListeners();
      return false;
    }
    // Email regex cơ bản (backend Zod có regex chặt hơn)
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email)) {
      _state = Error(message: 'Email không hợp lệ', retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();
    final res = await _repository.forgotPassword(_email);
    switch (res) {
      case ResultSuccess<String>(:final data):
        _state = Success(data.isEmpty ? '<no-token>' : data);
      case FailureResult<String>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
    return _state is Success<String>;
  }
}
