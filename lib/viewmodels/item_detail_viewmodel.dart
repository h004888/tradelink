import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final String itemId;

  UiState<Listing> _state = const Loading();
  UiState<Listing> get state => _state;
  bool _isSaved = false;
  bool get isSaved => _isSaved;

  ItemDetailViewModel({required this.itemId}) { load(); }

  Future<void> load() async {
    _state = const Loading(); notifyListeners();
    final result = await _repository.getListingById(itemId);
    switch (result) {
      case ResultSuccess(data: final l): _state = Success(l);
      case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void toggleSave() { _isSaved = !_isSaved; notifyListeners(); }
}
