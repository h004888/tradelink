import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  String _name = '';
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isTermsAccepted = false;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get isTermsAccepted => _isTermsAccepted;

  void onNameChanged(String value) => _name = value;
  void onEmailChanged(String value) => _email = value;
  void onPasswordChanged(String value) => _password = value;
  void toggleObscure() => _obscurePassword = !_obscurePassword;
  void toggleTerms() {
    _isTermsAccepted = !_isTermsAccepted;
    notifyListeners();
  }

  Future<bool> register() async {
    final trimmedName = _name.trim();
    if (trimmedName.length < 2) {
      _state = Error(message: 'Tên phải từ 2 ký tự trở lên', retryable: false);
      notifyListeners();
      return false;
    }
    if (_email.isEmpty || _password.length < 6) {
      _state = Error(message: 'Vui lòng nhập đầy đủ thông tin. Mật khẩu tối thiểu 6 ký tự.', retryable: false);
      notifyListeners();
      return false;
    }
    // Email format check — đồng bộ với backend Zod
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.trim())) {
      _state = Error(message: 'Email không hợp lệ', retryable: false);
      notifyListeners();
      return false;
    }
    if (!_isTermsAccepted) {
      _state = Error(message: 'Vui lòng đồng ý với Điều khoản dịch vụ', retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();
    final result = await _repository.register(_email.trim(), _password, trimmedName);
    if (result is ResultSuccess<bool>) {
      _state = const Success(null);
      AnalyticsService.instance.track('register_success');
      notifyListeners();
      return true;
    }
    final f = (result as FailureResult<bool>).failure;
    _state = Error(message: f.message, retryable: true);
    AnalyticsService.instance.track('register_failed', properties: {'reason': f.message});
    notifyListeners();
    return false;
  }
}
