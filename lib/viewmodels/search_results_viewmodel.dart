import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

enum SearchSort { relevance, priceAsc, priceDesc, popular, newest }

extension on SearchSort {
  String? get apiValue => switch (this) {
        SearchSort.relevance => null,
        SearchSort.priceAsc => 'price_asc',
        SearchSort.priceDesc => 'price_desc',
        SearchSort.popular => 'popular',
        SearchSort.newest => 'newest',
      };
}

class SearchResultsViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  // ── Search state ──
  UiState<List<Listing>> _state = const Idle();
  UiState<List<Listing>> get state => _state;

  String _query = '';
  String get query => _query;

  // ── Filter state ──
  ListingType? _typeFilter;
  ListingType? get typeFilter => _typeFilter;

  String? _categoryId;
  String? get categoryId => _categoryId;
  String? _categoryName;
  String? get categoryName => _categoryName;

  double? _minPrice;
  double? get minPrice => _minPrice;
  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  SearchSort _sort = SearchSort.relevance;
  SearchSort get sort => _sort;

  bool get hasActiveFilters =>
      _typeFilter != null || _categoryId != null || _minPrice != null || _maxPrice != null || _sort != SearchSort.relevance;

  // ── Suggestions state ──
  SearchSuggestions? _suggestions;
  SearchSuggestions? get suggestions => _suggestions;

  bool _showSuggestions = true;
  bool get showSuggestions => _showSuggestions;

  Timer? _debounce;

  // ── Recent searches (persisted qua SharedPreferences) ──
  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  // Dùng tạm khi chưa có dữ liệu tìm kiếm thật (server chưa đủ log) hoặc gọi API lỗi.
  static const List<String> _fallbackPopularSearches = [
    'iPhone', 'Laptop', 'Xe máy', 'Đồng hồ', 'Túi xách',
    'Máy ảnh', 'Tai nghe', 'Sách', 'Ghế văn phòng', 'Điện thoại',
  ];
  List<String> _popularSearches = _fallbackPopularSearches;
  List<String> get popularSearches => _popularSearches;

  SearchResultsViewModel() {
    _loadRecentSearches();
    _loadPopularSearches();
  }

  Future<void> _loadPopularSearches() async {
    final result = await _repository.getPopularSearches();
    if (result is ResultSuccess<List<String>> && result.data.isNotEmpty) {
      _popularSearches = result.data;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    _recentSearches = await StorageService.instance.getRecentSearches();
    notifyListeners();
  }

  void _persistRecentSearches() {
    StorageService.instance.saveRecentSearches(_recentSearches);
  }

  // ── Query handling ──
  void onQueryChanged(String value) {
    _query = value;
    _showSuggestions = true;

    _debounce?.cancel();
    if (value.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _searchSuggestions(value);
      });
    } else {
      _suggestions = null;
      notifyListeners();
    }
  }

  Future<void> _searchSuggestions(String query) async {
    final result = await _repository.getSuggestions(query);
    if (result is ResultSuccess<SearchSuggestions>) {
      _suggestions = result.data;
      notifyListeners();
    }
  }

  void submitQuery(String query) {
    if (query.isEmpty) return;
    _query = query;
    _showSuggestions = false;
    _suggestions = null;
    _addToRecentSearches(query);
    search(query);
  }

  void selectSuggestion(String suggestion) {
    _query = suggestion;
    _showSuggestions = false;
    _suggestions = null;
    _addToRecentSearches(suggestion);
    search(suggestion);
  }

  void clearSearch() {
    _query = '';
    _showSuggestions = true;
    _suggestions = null;
    _state = const Idle();
    notifyListeners();
  }

  // ── Recent searches ──
  void _addToRecentSearches(String query) {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) _recentSearches.removeLast();
    _persistRecentSearches();
    notifyListeners();
  }

  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    _persistRecentSearches();
    notifyListeners();
  }

  void clearAllRecentSearches() {
    _recentSearches.clear();
    _persistRecentSearches();
    notifyListeners();
  }

  // ── Search ──
  Future<void> search(String query) async {
    _query = query;
    _showSuggestions = false;
    _state = const Loading();
    notifyListeners();

    final result = await _repository.search(
      query: query,
      type: _typeFilter,
      categoryId: _categoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sort.apiValue,
    );

    _state = switch (result) {
      ResultSuccess(data: final list) => Success(list),
      FailureResult(failure: final f) => Error(message: f.message, retryable: true),
    };
    notifyListeners();
  }

  // ── Filters ──
  void setTypeFilter(ListingType? t) {
    _typeFilter = t;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  void setCategoryFilter(String? id, [String? name]) {
    _categoryId = id;
    _categoryName = id == null ? null : name;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  void setSort(SearchSort sort) {
    _sort = sort;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  /// Áp dụng đồng thời danh mục + khoảng giá + sắp xếp bằng 1 lần search() duy nhất.
  /// Tránh gọi setCategoryFilter/setPriceRange/setSort liên tiếp — mỗi hàm tự bắn
  /// một search() async riêng, dẫn tới race condition khi response về không đúng thứ tự.
  void applyFilters({
    String? categoryId,
    String? categoryName,
    double? minPrice,
    double? maxPrice,
    required SearchSort sort,
  }) {
    _categoryId = categoryId;
    _categoryName = categoryId == null ? null : categoryName;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _sort = sort;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  void clearFilters() {
    _typeFilter = null;
    _categoryId = null;
    _categoryName = null;
    _minPrice = null;
    _maxPrice = null;
    _sort = SearchSort.relevance;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  // ── Navigation ──
  void goToItem(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
  void goToListing(BuildContext context, String id) => context.push('${AppPaths.listingDetail}/$id');
}
