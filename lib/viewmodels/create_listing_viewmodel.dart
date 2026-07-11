import 'dart:io';
import 'package:flutter/material.dart';
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
    _state = const Loading();
    notifyListeners();

    final listing = Listing(
      id: 'lst-${DateTime.now().millisecondsSinceEpoch}',
      title: _title,
      description: _description,
      price: _price,
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
    _state = const Idle();
    notifyListeners();
  }
}
