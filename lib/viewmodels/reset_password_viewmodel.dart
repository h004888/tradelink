import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final String token;

  ResetPasswordViewModel({required this.token});

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  String _newPassword = '';
  String get newPassword => _newPassword;
  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;

  void setNew(String v) { _newPassword = v; notifyListeners(); }
  void setConfirm(String v) { _confirmPassword = v; notifyListeners(); }

  String? validate() {
    if (_newPassword.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (_newPassword != _confirmPassword) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  Future<bool> submit() async {
    final v = validate();
    if (v != null) {
      _state = Error(message: v, retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();
    final res = await _repository.resetPassword(token, _newPassword);
    switch (res) {
      case ResultSuccess<bool>():
        _state = const Success(null);
      case FailureResult<bool>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
    return _state is Success<void>;
  }
}
