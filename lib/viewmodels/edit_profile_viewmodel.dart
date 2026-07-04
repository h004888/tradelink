import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UiState<Profile> _loadState = const Loading();
  UiState<Profile> get loadState => _loadState;

  UiState<void> _saveState = const Idle();
  UiState<void> get saveState => _saveState;

  late String _name;
  String get name => _name;
  late String _phone;
  String get phone => _phone;
  late String _address;
  String get address => _address;

  EditProfileViewModel() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _loadState = const Loading();
    notifyListeners();

    final result = await _repository.getProfile();
    switch (result) {
      case ResultSuccess(data: final profile):
        _name = profile.name;
        _phone = profile.phone;
        _address = profile.address ?? '';
        _loadState = Success(profile);
      case FailureResult(failure: final failure):
        _loadState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  void onNameChanged(String v) => _name = v;
  void onPhoneChanged(String v) => _phone = v;
  void onAddressChanged(String v) => _address = v;

  Future<bool> save() async {
    _saveState = const Loading();
    notifyListeners();

    final profile = (_loadState as Success<Profile>).data;
    final updated = profile.copyWith(name: _name, phone: _phone, address: _address);

    final result = await _repository.updateProfile(updated);
    switch (result) {
      case ResultSuccess():
        _saveState = const Success(null);
        notifyListeners();
        return true;
      case FailureResult(failure: final failure):
        _saveState = Error(message: failure.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
