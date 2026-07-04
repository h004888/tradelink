import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class EditListingViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final String listingId;

  UiState<Listing> _loadState = const Loading();
  UiState<Listing> get loadState => _loadState;
  UiState<void> _saveState = const Idle();
  UiState<void> get saveState => _saveState;

  late Listing _listing;
  Listing get listing => _listing;

  EditListingViewModel({required this.listingId}) { _load(); }

  Future<void> _load() async {
    final result = await _repository.getListingById(listingId);
    switch (result) {
      case ResultSuccess(data: final l): _listing = l; _loadState = Success(l);
      case FailureResult(failure: final f): _loadState = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void updateField(void Function(Listing) update) { update(_listing); notifyListeners(); }

  Future<bool> save() async {
    _saveState = const Loading(); notifyListeners();
    final result = await _repository.updateListing(_listing);
    switch (result) {
      case ResultSuccess(): _saveState = const Success(null); notifyListeners(); return true;
      case FailureResult(failure: final f): _saveState = Error(message: f.message); notifyListeners(); return false;
    }
  }

  Future<void> delete(BuildContext context) async {
    await _repository.deleteListing(listingId);
    if (context.mounted) context.pop();
  }
}
