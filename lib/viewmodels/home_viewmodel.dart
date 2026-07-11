import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../services/analytics_service.dart';
import '../../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();

  // ── Sections ──
  UiState<List<Listing>> _featured = const Loading();
  UiState<List<Listing>> get featured => _featured;

  UiState<List<Listing>> _nearby = const Loading();
  UiState<List<Listing>> get nearby => _nearby;

  UiState<List<Listing>> _newest = const Loading();
  UiState<List<Listing>> get newest => _newest;

  UiState<List<Listing>> _popular = const Loading();
  UiState<List<Listing>> get popular => _popular;

  UiState<List<TopSellerInfo>> _topSellers = const Loading();
  UiState<List<TopSellerInfo>> get topSellers => _topSellers;

  // ── Categories filter (cho Featured) ──
  static const List<String> categories = [
    'Tất cả', 'Điện thoại', 'Laptop', 'Xe cộ',
    'Thời trang', 'Điện tử', 'Phụ kiện', 'Đồ gia dụng', 'Khác',
  ];
  int _selectedCategory = 0;
  int get selectedCategory => _selectedCategory;
  String get selectedCategoryName => categories[_selectedCategory];

  HomeViewModel() { load(); }

  /// Helper generic: gọi API, trả về UiState — mỗi section xử lý error riêng
  Future<UiState<T>> _safeLoad<T>(Future<Result<T>> apiCall) async {
    try {
      final result = await apiCall;
      if (result is ResultSuccess<T>) {
        return Success(result.data);
      }
      return Error(
        message: (result as FailureResult<T>).failure.message,
        retryable: true,
      );
    } catch (e) {
      debugPrint('[HomeViewModel] Section error: $e');
      return const Error(message: 'Đã xảy ra lỗi không mong đợi', retryable: true);
    }
  }

  Future<void> load() async {
    AnalyticsService.instance.track('home_viewed');

    // Set loading state cho tất cả section
    _featured = const Loading();
    _nearby = const Loading();
    _newest = const Loading();
    _popular = const Loading();
    _topSellers = const Loading();
    notifyListeners();

    // Fire parallel — mỗi section tự xử lý success/error riêng
    final results = await Future.wait([
      _safeLoad<List<Listing>>(_repository.getFeaturedListings()),
      _safeLoad<List<Listing>>(_repository.getNewestListings()),
      _safeLoad<List<Listing>>(_repository.getPopularListings()),
      _safeLoad<List<Listing>>(_repository.getNewestListings()), // Fallback: newest cho nearby
      _safeLoad<List<TopSellerInfo>>(_repository.getTopSellers()),
    ]);

    _featured = results[0] as UiState<List<Listing>>;
    _newest = results[1] as UiState<List<Listing>>;
    _popular = results[2] as UiState<List<Listing>>;
    _nearby = results[3] as UiState<List<Listing>>;
    _topSellers = results[4] as UiState<List<TopSellerInfo>>;
    notifyListeners();
  }

  Future<void> selectCategory(int i) async {
    _selectedCategory = i;
    notifyListeners();
    final category = i == 0 ? null : selectedCategoryName;
    final result = await _repository.getAllListings(category: category, status: 'active');
    _featured = result.isSuccess
        ? Success((result as ResultSuccess<List<Listing>>).data)
        : Error(message: (result as FailureResult<List<Listing>>).failure.message, retryable: true);
    notifyListeners();
  }

  void goToSearch(BuildContext context) => context.push(AppPaths.search);
  void goToCategory(BuildContext context, String name) =>
      context.push('${AppPaths.category}/${Uri.encodeComponent(name)}');
  void goToItemDetail(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
  void goToSellerProfile(BuildContext context, String userId) =>
      context.push('${AppPaths.sellerProfile}/$userId');
  void goToAllNewest(BuildContext context) => context.push(AppPaths.search);
  void goToAllPopular(BuildContext context) => context.push(AppPaths.search);
}
