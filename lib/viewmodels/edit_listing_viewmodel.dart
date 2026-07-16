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

  EditListingViewModel({required this.listingId}) { load(); }

  /// Public reload method — cho phép View gọi retry khi loadState là Error.
  Future<void> load() async {
    _loadState = const Loading();
    notifyListeners();
    final result = await _repository.getListingById(listingId);
    switch (result) {
      case ResultSuccess(data: final l): _listing = l; _loadState = Success(l);
      case FailureResult(failure: final f): _loadState = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void updateField(Listing Function(Listing) update) { _listing = update(_listing); notifyListeners(); }

  Future<bool> save() async {
    if (_listing.title.isEmpty || _listing.description.isEmpty) {
      _saveState = const Error(message: 'Tiêu đề và mô tả không được để trống'); notifyListeners(); return false;
    }
    if (_listing.type == ListingType.sale && _listing.price == null) {
      _saveState = const Error(message: 'Vui lòng nhập giá bán'); notifyListeners(); return false;
    }
    if (_listing.type == ListingType.trade && (_listing.exchangeFor == null || _listing.exchangeFor!.isEmpty)) {
      _saveState = const Error(message: 'Vui lòng mô tả món đồ bạn muốn đổi'); notifyListeners(); return false;
    }
    if (_listing.type == ListingType.both && (_listing.price == null || _listing.exchangeFor == null || _listing.exchangeFor!.isEmpty)) {
      _saveState = const Error(message: 'Vui lòng nhập giá bán và mô tả món đồ muốn đổi'); notifyListeners(); return false;
    }

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
