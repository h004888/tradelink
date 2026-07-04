import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/ui_state.dart';
import '../../utils/constants.dart';

class SplashViewModel extends ChangeNotifier {
  UiState<void> _state = const Loading();
  UiState<void> get state => _state;

  SplashViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(AppDurations.splashDelay);
    _state = const Success(null);
    notifyListeners();
  }

  void navigateNext(BuildContext context) {
    // TODO: Check stored auth token — if valid, go to home; else onboarding
    context.go(AppPaths.onboarding);
  }
}
