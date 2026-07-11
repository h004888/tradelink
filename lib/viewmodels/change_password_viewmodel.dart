import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  String _oldPassword = '';
  String get oldPassword => _oldPassword;
  String _newPassword = '';
  String get newPassword => _newPassword;
  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;

  void setOld(String v) { _oldPassword = v; notifyListeners(); }
  void setNew(String v) { _newPassword = v; notifyListeners(); }
  void setConfirm(String v) { _confirmPassword = v; notifyListeners(); }

  String? validate() {
    if (_oldPassword.isEmpty) return 'Vui lòng nhập mật khẩu cũ';
    if (_newPassword.length < 6) return 'Mật khẩu mới tối thiểu 6 ký tự';
    if (_newPassword != _confirmPassword) return 'Mật khẩu xác nhận không khớp';
    if (_oldPassword == _newPassword) return 'Mật khẩu mới không được trùng mật khẩu cũ';
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
    final res = await _repository.changePassword(_oldPassword, _newPassword);
    switch (res) {
      case ResultSuccess<bool>():
        _state = const Success(null);
        notifyListeners();
        return true;
      case FailureResult<bool>(:final failure):
        _state = Error(message: failure.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
