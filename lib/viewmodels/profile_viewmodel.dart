import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../utils/constants.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UiState<Profile> _state = const Loading();
  UiState<Profile> get state => _state;

  Profile? get profile => _state is Success<Profile> ? (_state as Success<Profile>).data : null;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.getProfile();
    switch (result) {
      case ResultSuccess(data: final profile):
        _state = Success(profile);
      case FailureResult(failure: final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  void navigateToEditProfile(BuildContext context) {
    context.push(AppPaths.editProfile);
  }

  void navigateToMyListings(BuildContext context) {
    context.push(AppPaths.myListings);
  }

  void navigateToSettings(BuildContext context) {
    // TODO: Settings screen
  }

  void logout(BuildContext context) {
    context.go(AppPaths.login);
  }
}
