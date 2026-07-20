import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../core/events.dart';
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

  StreamSubscription? _listingDeletedSub;

  MyListingsViewModel() { 
    loadListings(); 
    _listingDeletedSub = EventBus.onListingDeleted.listen(removeListing);
  }

  @override
  void dispose() {
    _listingDeletedSub?.cancel();
    super.dispose();
  }

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

  void setFilter(ListingStatus status) {
    if (_filter == status) return;
    _filter = status;
    loadListings();
  }

  void removeListing(String id) {
    if (_state is Success<List<Listing>>) {
      final currentList = (_state as Success<List<Listing>>).data;
      final updatedList = currentList.where((l) => l.id != id).toList();
      _state = Success(updatedList);
      notifyListeners();
    }
  }
}
