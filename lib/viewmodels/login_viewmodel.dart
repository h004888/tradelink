import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final String? _redirectPath;

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  String? get redirectPath => _redirectPath;

  LoginViewModel({String? redirectPath}) : _redirectPath = redirectPath;

  void onEmailChanged(String value) => _email = value;
  void onPasswordChanged(String value) => _password = value;
  void toggleObscure() => _obscurePassword = !_obscurePassword;

  Future<bool> login() async {
    if (_email.isEmpty || _password.isEmpty) {
      _state = Error(message: 'Vui lòng nhập email và mật khẩu');
      notifyListeners();
      return false;
    }
    // Email format check — đồng bộ với backend Zod
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.trim())) {
      _state = Error(message: 'Email không hợp lệ', retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();
    final result = await _repository.loginWithPassword(_email.trim(), _password);
    if (result is ResultSuccess<bool>) {
      _state = const Success(null);
      AnalyticsService.instance.track('login_success', properties: _redirectPath != null ? {'redirected': true} : null);
      notifyListeners();
      return true;
    }
    final f = (result as FailureResult<bool>).failure;
    _state = Error(message: f.message, retryable: true);
    AnalyticsService.instance.track('login_failed', properties: {'reason': f.message});
    notifyListeners();
    return false;
  }
}
