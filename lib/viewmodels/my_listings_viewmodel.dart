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

  List<Listing> get listings => _state is Success<List<Listing>> ? (_state as Success<List<Listing>>).data : [];

  MyListingsViewModel() { loadListings(); }

  Future<void> loadListings() async {
    _state = const Loading();
    notifyListeners();
    final result = await _repository.getMyListings(filter: _filter);
    switch (result) {
      case ResultSuccess(data: final list): _state = Success(list.where((l) => l.status != ListingStatus.draft).toList());
      case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void setFilter(ListingStatus f) { _filter = f; loadListings(); }
}
