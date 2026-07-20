import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../core/api_client.dart';
import '../../core/events.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../utils/constants.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final String listingId;

  UiState<Listing> _state = const Loading();
  UiState<Listing> get state => _state;
  
  bool _isOwner = false;
  bool get isOwner => _isOwner;

  Listing? get listing => _state is Success<Listing> ? (_state as Success<Listing>).data : null;

  ListingDetailViewModel({required this.listingId}) { load(); }

  Future<void> load() async {
    _state = const Loading(); notifyListeners();
    final result = await _repository.getListingById(listingId);
    switch (result) {
      case ResultSuccess(data: final l): 
        _state = Success(l);
        _isOwner = l.sellerId == ApiClient.instance.getUserId();
      case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void edit(BuildContext context) => context.push('${AppPaths.editListing}/$listingId');
  void boost(BuildContext context) => context.push('${AppPaths.boostListing}/$listingId');
  
  Future<bool> delete(BuildContext context) async {
    try {
      await _repository.deleteListing(listingId);
      EventBus.fireListingDeleted(listingId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleVisibility(BuildContext context, {required bool isHidden}) async {
    try {
      final res = isHidden 
          ? await _repository.unhideListing(listingId)
          : await _repository.hideListing(listingId);
          
      if (res is ResultSuccess<Listing>) {
        // Cập nhật lại UI detail view
        _state = Success(res.data);
        notifyListeners();
        
        // Notify the feed lists
        if (isHidden) {
          EventBus.fireListingCreated(res.data); // Add back to feed
          EventBus.fireListingStatusChanged(ListingStatus.active); // Tell MyListings to switch tab
        } else {
          EventBus.fireListingDeleted(listingId); // Remove from feed
          EventBus.fireListingStatusChanged(ListingStatus.hidden);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
