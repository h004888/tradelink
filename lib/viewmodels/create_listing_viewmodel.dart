import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/upload_repository.dart';
import '../../core/events.dart';
import '../../core/api_client.dart';
import 'home_category_viewmodel.dart' show CategoryItem;

class CreateListingViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final UploadRepository _upload = UploadRepository();
  final ImagePicker _picker = ImagePicker();
  
  final Listing? draft;

  CreateListingViewModel({this.draft}) {
    if (draft != null) {
      _type = draft!.type;
      _title = draft!.title;
      _description = draft!.description;
      _price = draft!.price;
      _exchangeFor = draft!.exchangeFor;
      _category = draft!.category;
      _categoryId = draft!.categoryId;
      _condition = draft!.condition;
      _imageUrls.addAll(draft!.imageUrls);
    }
    _loadCategories();
  }

  UiState<Listing> _state = const Idle();
  UiState<Listing> get state => _state;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Form fields
  ListingType _type = ListingType.sale;
  ListingType get type => _type;
  String _title = '';
  String get title => _title;
  String? _titleError;
  String? get titleError => _titleError;

  String _description = '';
  String get description => _description;
  String? _descriptionError;
  String? get descriptionError => _descriptionError;

  double? _price;
  double? get price => _price;
  String? _priceError;
  String? get priceError => _priceError;

  String? _exchangeFor;
  String? get exchangeFor => _exchangeFor;
  String? _exchangeForError;
  String? get exchangeForError => _exchangeForError;
  String _category = '';
  String get category => _category;
  String? _categoryId;
  String? get categoryId => _categoryId;
  UiState<List<CategoryItem>> _categoriesState = const Loading();
  UiState<List<CategoryItem>> get categoriesState => _categoriesState;
  ItemCondition _condition = ItemCondition.used;
  ItemCondition get condition => _condition;
  final List<String> _imageUrls = [];
  List<String> get imageUrls => _imageUrls;
  final List<XFile> _localImages = [];
  List<XFile> get localImages => _localImages;
  String? _imageError;
  String? get imageError => _imageError;

  /// Danh mục thật lấy từ server — trước đây là list cứng, khiến tin đăng không
  /// bao giờ có categoryId hợp lệ nên bị lọt khỏi filter "Danh mục" khi tìm kiếm.
  Future<void> _loadCategories() async {
    final res = await ApiClient.instance.get('/categories');
    if (res is ResultSuccess<Map<String, dynamic>>) {
      final list = ((res.data['data'] as List?) ?? [])
          .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _categoriesState = Success(list);
      if (_categoryId == null && list.isNotEmpty) {
        _categoryId = list.first.id;
        _category = list.first.name;
      }
    } else {
      _categoriesState = Error(message: 'Không tải được danh mục', retryable: true);
    }
    notifyListeners();
  }

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

  void setType(ListingType t) { _type = t; _priceError = null; _exchangeForError = null; notifyListeners(); }
  void setTitle(String v) { _title = v; if (_titleError != null) { _titleError = null; notifyListeners(); } }
  void setDescription(String v) { _description = v; if (_descriptionError != null) { _descriptionError = null; notifyListeners(); } }
  void setPrice(String v) { _price = double.tryParse(v); if (_priceError != null) { _priceError = null; notifyListeners(); } }
  void setExchangeFor(String v) { _exchangeFor = v; if (_exchangeForError != null) { _exchangeForError = null; notifyListeners(); } }
  void setCategory(String id, String name) {
    _categoryId = id;
    _category = name;
    notifyListeners();
  }
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
      _isUploading = true;
      notifyListeners();
      final res = await _upload.uploadOne(picked);
      _isUploading = false;
      if (res is FailureResult<String>) {
        _state = Error(message: (res).failure.message, retryable: true);
      } else {
        _imageUrls.add((res as ResultSuccess<String>).data);
        _localImages.add(picked);
        _imageError = null;
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

  Future<Listing?> publish() async {
    bool hasError = false;
    
    if (_title.isEmpty) { _titleError = 'Vui lòng nhập tiêu đề'; hasError = true; } else _titleError = null;
    if (_description.isEmpty) { _descriptionError = 'Vui lòng nhập mô tả chi tiết'; hasError = true; } else _descriptionError = null;
    if (_imageUrls.isEmpty) { _imageError = 'Vui lòng chọn ít nhất 1 ảnh'; hasError = true; } else _imageError = null;
    
    if (_type == ListingType.sale || _type == ListingType.both) {
      if (_price == null) { _priceError = 'Vui lòng nhập giá bán'; hasError = true; } else _priceError = null;
    } else _priceError = null;

    if (_type == ListingType.trade || _type == ListingType.both) {
      if (_exchangeFor == null || _exchangeFor!.isEmpty) { _exchangeForError = 'Vui lòng mô tả món đồ bạn muốn đổi'; hasError = true; } else _exchangeForError = null;
    } else _exchangeForError = null;

    if (hasError) {
      notifyListeners();
      return null;
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
      categoryId: _categoryId,
      condition: _condition,
      type: _type,
      sellerId: ApiClient.instance.getUserId() ?? 'unknown-user',
      sellerName: 'Nguyễn Minh Khôi',
      createdAt: DateTime.now(),
    );

    final result = await _repository.createListing(listing);
    if (result is ResultSuccess<Listing>) {
      EventBus.fireListingCreated(result.data);
      _state = Success(result.data);
      notifyListeners();
      return result.data;
    }
    if (result is FailureResult<Listing>) {
      _state = Error(message: result.failure.message, retryable: true);
      notifyListeners();
      return null;
    }
    return null;
  }

  Future<bool> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftList = prefs.getStringList('draft_listings') ?? [];
    
    final draftObj = {
      'id': draft?.id ?? 'draft-${DateTime.now().millisecondsSinceEpoch}',
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
    
    if (draft != null) {
      // Update existing
      final index = draftList.indexWhere((s) {
        try {
          return jsonDecode(s)['id'] == draft!.id;
        } catch (_) {
          return false;
        }
      });
      if (index >= 0) {
        draftList[index] = jsonEncode(draftObj);
      } else {
        draftList.add(jsonEncode(draftObj));
      }
    } else {
      draftList.add(jsonEncode(draftObj));
    }
    
    await prefs.setStringList('draft_listings', draftList);
    
    _state = const Idle();
    notifyListeners();
    return true;
  }

  void reset() {
    _type = ListingType.sale;
    _title = '';
    _titleError = null;
    _description = '';
    _descriptionError = null;
    _price = null;
    _priceError = null;
    _exchangeFor = null;
    _exchangeForError = null;
    if (_categoriesState case Success(data: final cats) when cats.isNotEmpty) {
      _categoryId = cats.first.id;
      _category = cats.first.name;
    } else {
      _categoryId = null;
      _category = '';
    }
    _condition = ItemCondition.used;
    _imageUrls.clear();
    _localImages.clear();
    _imageError = null;
    _state = const Idle();
    notifyListeners();
  }
}
