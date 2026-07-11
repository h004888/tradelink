import 'package:flutter/material.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _auth = AuthRepository();

  UiState<void> _logoutState = const Idle();
  UiState<void> get logoutState => _logoutState;

  Future<bool> logout() async {
    _logoutState = const Loading();
    notifyListeners();
    try {
      await _auth.logout();
      _logoutState = const Success(null);
      notifyListeners();
      return true;
    } catch (e) {
      _logoutState = Error(message: 'Không đăng xuất được: $e', retryable: true);
      notifyListeners();
      return false;
    }
  }
}
