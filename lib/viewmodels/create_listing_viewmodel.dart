import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class CreateListingViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();

  UiState<Listing> _state = const Idle();
  UiState<Listing> get state => _state;

  // Form fields
  ListingType _type = ListingType.sale;
  ListingType get type => _type;
  String _title = '';
  String get title => _title;
  String _description = '';
  String get description => _description;
  double? _price;
  double? get price => _price;
  String _category = 'Điện tử';
  String get category => _category;
  ItemCondition _condition = ItemCondition.used;
  ItemCondition get condition => _condition;
  final List<String> _imageUrls = [];
  List<String> get imageUrls => _imageUrls;

  static const List<String> categories = ['Điện tử', 'Điện thoại', 'Phụ kiện', 'Xe cộ', 'Nội thất', 'Thời trang', 'Sách', 'Khác'];

  int get completionPercent {
    int filled = 0;
    if (_title.isNotEmpty) filled++;
    if (_description.isNotEmpty) filled++;
    if (_imageUrls.isNotEmpty) filled++;
    if (_price != null || _type != ListingType.sale) filled++;
    if (_category.isNotEmpty) filled++;
    return (filled / 5 * 100).round();
  }

  void setType(ListingType t) { _type = t; notifyListeners(); }
  void setTitle(String v) { _title = v; }
  void setDescription(String v) { _description = v; }
  void setPrice(String v) { _price = double.tryParse(v); }
  void setCategory(String v) { _category = v; notifyListeners(); }
  void setCondition(ItemCondition c) { _condition = c; notifyListeners(); }
  void addImage(String url) { _imageUrls.add(url); notifyListeners(); }
  void removeImage(int index) { _imageUrls.removeAt(index); notifyListeners(); }

  Future<bool> publish() async {
    _state = const Loading();
    notifyListeners();

    final listing = Listing(
      id: 'lst-${DateTime.now().millisecondsSinceEpoch}',
      title: _title, description: _description, price: _price,
      imageUrls: _imageUrls, category: _category, condition: _condition,
      type: _type, sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi',
      createdAt: DateTime.now(),
    );

    final result = await _repository.createListing(listing);
    switch (result) {
      case ResultSuccess(data: final l):
        _state = Success(l);
        notifyListeners();
        return true;
      case FailureResult(failure: final f):
        _state = Error(message: f.message, retryable: true);
        notifyListeners();
        return false;
    }
  }

  Future<void> saveDraft() async {
    // Save locally — for now just mark as draft
    _state = const Idle();
    notifyListeners();
  }
}
