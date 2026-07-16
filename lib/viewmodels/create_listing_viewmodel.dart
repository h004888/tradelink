import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/upload_repository.dart';

class CreateListingViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final UploadRepository _upload = UploadRepository();
  final ImagePicker _picker = ImagePicker();

  UiState<Listing> _state = const Idle();
  UiState<Listing> get state => _state;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Form fields
  ListingType _type = ListingType.sale;
  ListingType get type => _type;
  String _title = '';
  String get title => _title;
  String _description = '';
  String get description => _description;
  double? _price;
  double? get price => _price;
  String? _exchangeFor;
  String? get exchangeFor => _exchangeFor;
  String _category = 'Điện tử';
  String get category => _category;
  ItemCondition _condition = ItemCondition.used;
  ItemCondition get condition => _condition;
  final List<String> _imageUrls = [];
  List<String> get imageUrls => _imageUrls;
  final List<File> _localImages = [];
  List<File> get localImages => _localImages;

  static const List<String> categories = ['Điện tử', 'Điện thoại', 'Phụ kiện', 'Xe cộ', 'Nội thất', 'Thời trang', 'Sách', 'Khác'];

  int get completionPercent {
    int filled = 0;
    if (_title.isNotEmpty) filled++;
    if (_description.isNotEmpty) filled++;
    if (_imageUrls.isNotEmpty) filled++;
    
    bool hasPrice = _price != null;
    bool hasExchange = _exchangeFor != null && _exchangeFor!.isNotEmpty;
    if ((_type == ListingType.sale && hasPrice) || 
        (_type == ListingType.trade && hasExchange) ||
        (_type == ListingType.both && hasPrice && hasExchange)) {
      filled++;
    }
    
    if (_category.isNotEmpty) filled++;
    return (filled / 5 * 100).round();
  }

  void setType(ListingType t) { _type = t; notifyListeners(); }
  void setTitle(String v) { _title = v; }
  void setDescription(String v) { _description = v; }
  void setPrice(String v) { _price = double.tryParse(v); }
  void setExchangeFor(String v) { _exchangeFor = v; }
  void setCategory(String v) { _category = v; notifyListeners(); }
  void setCondition(ItemCondition c) { _condition = c; notifyListeners(); }

  /// Mở image picker, upload ảnh đã chọn, lưu URL trả về vào imageUrls.
  Future<void> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    if (_isUploading) return;
    if (_imageUrls.length + _localImages.length >= 8) {
      _state = Error(message: 'Tối đa 8 ảnh cho 1 tin đăng', retryable: false);
      notifyListeners();
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;
      final file = File(picked.path);
      _isUploading = true;
      notifyListeners();
      final res = await _upload.uploadOne(file);
      _isUploading = false;
      if (res is FailureResult<String>) {
        _state = Error(message: (res).failure.message, retryable: true);
      } else {
        _imageUrls.add((res as ResultSuccess<String>).data);
        _localImages.add(file);
      }
    } catch (e) {
      _isUploading = false;
      _state = Error(message: 'Không chọn được ảnh: $e', retryable: true);
    }
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= _imageUrls.length) return;
    _imageUrls.removeAt(index);
    if (index < _localImages.length) {
      _localImages.removeAt(index);
    }
    notifyListeners();
  }

  Future<bool> publish() async {
    if (_title.isEmpty || _description.isEmpty || _imageUrls.isEmpty) {
      _state = const Error(message: 'Vui lòng điền tiêu đề, mô tả và tải lên ít nhất 1 ảnh', retryable: false);
      notifyListeners();
      return false;
    }
    
    if (_type == ListingType.sale && _price == null) {
      _state = const Error(message: 'Vui lòng nhập giá bán', retryable: false);
      notifyListeners();
      return false;
    }
    if (_type == ListingType.trade && (_exchangeFor == null || _exchangeFor!.isEmpty)) {
      _state = const Error(message: 'Vui lòng mô tả món đồ bạn muốn đổi', retryable: false);
      notifyListeners();
      return false;
    }
    if (_type == ListingType.both && (_price == null || _exchangeFor == null || _exchangeFor!.isEmpty)) {
      _state = const Error(message: 'Vui lòng nhập giá bán và mô tả món đồ muốn đổi', retryable: false);
      notifyListeners();
      return false;
    }

    _state = const Loading();
    notifyListeners();

    final listing = Listing(
      id: 'lst-${DateTime.now().millisecondsSinceEpoch}',
      title: _title,
      description: _description,
      price: _price,
      exchangeFor: _exchangeFor,
      imageUrls: _imageUrls,
      category: _category,
      condition: _condition,
      type: _type,
      sellerId: 'user-001',
      sellerName: 'Nguyễn Minh Khôi',
      createdAt: DateTime.now(),
    );

    final result = await _repository.createListing(listing);
    if (result is ResultSuccess<Listing>) {
      _state = Success(result.data);
      notifyListeners();
      return true;
    }
    if (result is FailureResult<Listing>) {
      _state = Error(message: result.failure.message, retryable: true);
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftList = prefs.getStringList('draft_listings') ?? [];
    
    final draft = {
      'id': 'draft-${DateTime.now().millisecondsSinceEpoch}',
      'title': _title,
      'description': _description,
      'price': _price,
      'exchangeFor': _exchangeFor,
      'imageUrls': _imageUrls,
      'category': _category,
      'condition': _condition.name,
      'type': _type.name,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    draftList.add(jsonEncode(draft));
    await prefs.setStringList('draft_listings', draftList);
    
    _state = const Idle();
    notifyListeners();
  }
}
