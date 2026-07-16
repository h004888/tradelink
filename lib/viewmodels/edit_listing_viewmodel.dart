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

  String? _titleError;
  String? get titleError => _titleError;
  String? _descriptionError;
  String? get descriptionError => _descriptionError;
  String? _priceError;
  String? get priceError => _priceError;
  String? _exchangeForError;
  String? get exchangeForError => _exchangeForError;

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

  void updateField(Listing Function(Listing) update) { 
    _listing = update(_listing); 
    _titleError = null;
    _descriptionError = null;
    _priceError = null;
    _exchangeForError = null;
    notifyListeners(); 
  }

  Future<bool> save() async {
    bool hasError = false;
    
    if (_listing.title.isEmpty) { _titleError = 'Vui lòng nhập tiêu đề'; hasError = true; } else _titleError = null;
    if (_listing.description.isEmpty) { _descriptionError = 'Vui lòng nhập mô tả'; hasError = true; } else _descriptionError = null;
    
    if (_listing.type == ListingType.sale || _listing.type == ListingType.both) {
      if (_listing.price == null) { _priceError = 'Vui lòng nhập giá bán'; hasError = true; } else _priceError = null;
    } else _priceError = null;

    if (_listing.type == ListingType.trade || _listing.type == ListingType.both) {
      if (_listing.exchangeFor == null || _listing.exchangeFor!.isEmpty) { _exchangeForError = 'Vui lòng mô tả món đồ bạn muốn đổi'; hasError = true; } else _exchangeForError = null;
    } else _exchangeForError = null;

    if (hasError) {
      notifyListeners();
      return false;
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
