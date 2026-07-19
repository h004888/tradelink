import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../utils/constants.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UiState<Profile> _state = const Loading();
  UiState<Profile> get state => _state;

  Profile? get profile {
    final s = _state;
    if (s is Success<Profile>) return s.data;
    return null;
  }

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.getProfile();
    if (result is ResultSuccess<Profile>) {
      _state = Success(result.data);
    } else if (result is FailureResult<Profile>) {
      _state = Error(message: (result).failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> navigateToEditProfile(BuildContext context) async {
    await context.push(AppPaths.editProfile);
  }

  Future<void> navigateToMyListings(BuildContext context) async {
    await context.push(AppPaths.myListings);
  }

  void navigateToWatchlist(BuildContext context) {
    context.push(AppPaths.watchlist);
  }

  void navigateToSettings(BuildContext context) {
    context.push(AppPaths.settings);
  }

  Future<void> logout(BuildContext context) async {
    // Gọi API logout (optional — để backend track), rồi clear token local + navigate
    await AuthRepository().logout();
    await ApiClient.instance.clearTokens();
    if (context.mounted) context.go(AppPaths.login);
  }
}
