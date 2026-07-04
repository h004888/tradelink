import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/constants.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UiState<String> _state = const Idle();
  UiState<String> get state => _state;

  String _phone = '';
  String get phone => _phone;

  void onPhoneChanged(String value) {
    _phone = value;
  }

  Future<void> login() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.login(_phone);

    switch (result) {
      case ResultSuccess(data: final sessionId):
        _state = Success(sessionId);
      case FailureResult(failure: final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  void navigateToOtp(BuildContext context) {
    context.go(AppPaths.otpVerification);
  }
}
