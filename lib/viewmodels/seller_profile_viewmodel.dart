import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../models/seller_profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../utils/constants.dart';

class SellerProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  final String userId;

  UiState<PublicSellerProfile> _state = const Loading();
  UiState<PublicSellerProfile> get state => _state;

  SellerProfileViewModel({required this.userId});

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.getPublicProfile(userId);
    _state = switch (result) {
      ResultSuccess(data: final profile) => Success(profile),
      FailureResult(failure: final f) => Error(message: f.message, retryable: true),
    };
    notifyListeners();
  }

  void goToItemDetail(BuildContext context, String id) {
    context.push('${AppPaths.itemDetail}/$id');
  }
}
