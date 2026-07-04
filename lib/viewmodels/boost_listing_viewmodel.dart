import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/listing_repository.dart';

class BoostListingViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final String listingId;

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;
  int _selectedDays = 3;
  int get selectedDays => _selectedDays;
  int get price => _selectedDays == 3 ? 20000 : 50000;

  BoostListingViewModel({required this.listingId});

  void selectDays(int d) { _selectedDays = d; notifyListeners(); }

  Future<bool> boost() async {
    _state = const Loading(); notifyListeners();
    final result = await _repository.boostListing(listingId, _selectedDays);
    switch (result) {
      case ResultSuccess(): _state = const Success(null); notifyListeners(); return true;
      case FailureResult(failure: final f): _state = Error(message: f.message); notifyListeners(); return false;
    }
  }
}
