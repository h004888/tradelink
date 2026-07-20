import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _auth = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  UiState<void> _logoutState = const Idle();
  UiState<void> get logoutState => _logoutState;

  bool _isNotificationEnabled = true;
  bool get isNotificationEnabled => _isNotificationEnabled;

  String _selectedLanguage = 'vi';
  String get selectedLanguage => _selectedLanguage;

  UiState<void> _settingsState = const Idle();
  UiState<void> get settingsState => _settingsState;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isNotificationEnabled =
        await StorageService.instance.getNotificationEnabled();
    _selectedLanguage = await StorageService.instance.getSelectedLanguage();
    notifyListeners();
  }

  Future<void> updateNotificationEnabled(bool enabled) async {
    final previous = _isNotificationEnabled;
    _isNotificationEnabled = enabled;
    _settingsState = const Loading();
    notifyListeners();

    await StorageService.instance.saveNotificationEnabled(enabled);
    final result = await _profileRepository.updateSettings(
      notifications: enabled,
      language: _selectedLanguage,
    );
    if (result is ResultSuccess<bool>) {
      _settingsState = const Success(null);
    } else {
      _isNotificationEnabled = previous;
      await StorageService.instance.saveNotificationEnabled(previous);
      _settingsState =
          Error(message: (result as FailureResult<bool>).failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    if (language == _selectedLanguage) return;

    final previous = _selectedLanguage;
    _selectedLanguage = language;
    _settingsState = const Loading();
    notifyListeners();

    await StorageService.instance.saveSelectedLanguage(language);
    final result = await _profileRepository.updateSettings(
      notifications: _isNotificationEnabled,
      language: language,
    );
    if (result is ResultSuccess<bool>) {
      _settingsState = const Success(null);
    } else {
      _selectedLanguage = previous;
      await StorageService.instance.saveSelectedLanguage(previous);
      _settingsState =
          Error(message: (result as FailureResult<bool>).failure.message, retryable: true);
    }
    notifyListeners();
  }

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
