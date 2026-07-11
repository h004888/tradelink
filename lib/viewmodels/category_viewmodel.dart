import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../utils/constants.dart';

class CategoryViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final String categoryName;

  UiState<List<Listing>> _state = const Idle();
  UiState<List<Listing>> get state => _state;

  CategoryViewModel({required this.categoryName});

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.getAllListings(
      category: categoryName == 'Tất cả' ? null : categoryName,
      status: 'active',
    );

    _state = switch (result) {
      ResultSuccess(data: final list) => Success(list),
      FailureResult(failure: final f) => Error(message: f.message, retryable: true),
    };
    notifyListeners();
  }

  void goToItemDetail(BuildContext context, String id) {
    context.push('${AppPaths.itemDetail}/$id');
  }
}
