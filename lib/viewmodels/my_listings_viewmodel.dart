import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class MyListingsViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();

  UiState<List<Listing>> _state = const Loading();
  UiState<List<Listing>> get state => _state;

  ListingStatus _filter = ListingStatus.active;
  ListingStatus get filter => _filter;

  List<Listing> get listings {
    final s = _state;
    if (s is Success<List<Listing>>) return s.data;
    return const [];
  }

  MyListingsViewModel() { loadListings(); }

  Future<void> loadListings() async {
    _state = const Loading();
    notifyListeners();
    final result = await _repository.getMyListings(filter: _filter);
    if (result is ResultSuccess<List<Listing>>) {
      _state = Success(result.data.where((l) => l.status != ListingStatus.draft).toList());
    } else if (result is FailureResult<List<Listing>>) {
      _state = Error(message: result.failure.message, retryable: true);
    }
    notifyListeners();
  }

  void setFilter(ListingStatus f) { _filter = f; loadListings(); }
}
