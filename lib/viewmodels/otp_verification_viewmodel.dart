import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/constants.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UiState<bool> _state = const Idle();
  UiState<bool> get state => _state;

  String _otp = '';
  String get otp => _otp;

  int _secondsRemaining = 60;
  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _secondsRemaining == 0;

  Timer? _timer;

  OtpVerificationViewModel() {
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void onOtpChanged(String value) {
    if (value.length <= 6) {
      _otp = value;
      notifyListeners();
    }
  }

  Future<void> verify() async {
    if (_otp.length != 6) return;

    _state = const Loading();
    notifyListeners();

    final result = await _repository.verifyOtp('session-mock', _otp);

    switch (result) {
      case ResultSuccess():
        _state = const Success(true);
      case FailureResult(failure: final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  void resend() {
    _startTimer();
    notifyListeners();
  }

  void navigateToHome(BuildContext context) {
    _timer?.cancel();
    context.go(AppPaths.home);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
