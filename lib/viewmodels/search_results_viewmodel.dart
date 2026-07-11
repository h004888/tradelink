import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class SearchResultsViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  UiState<List<Listing>> _state = const Idle();
  UiState<List<Listing>> get state => _state;

  String _query = '';
  String get query => _query;

  ListingType? _typeFilter;
  String? _categoryFilter;

  // ── Suggestions ──
  bool _showSuggestions = true;
  bool get showSuggestions => _showSuggestions;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  static const List<String> _popularSearches = [
    'iPhone', 'Laptop', 'Xe máy', 'Đồng hồ', 'Túi xách',
    'Máy ảnh', 'Tai nghe', 'Sách', 'Ghế văn phòng', 'Điện thoại',
  ];
  List<String> get popularSearches => _popularSearches;

  SearchResultsViewModel() {
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    // Lấy recent searches từ storage (in-memory cho đơn giản)
    // Có thể mở rộng sau với PersistentStorage
    _recentSearches = ['iPhone 15', 'Laptop Dell', 'Xe máy'];
    notifyListeners();
  }

  void onQueryChanged(String value) {
    _query = value;
    _showSuggestions = true;
    notifyListeners();
  }

  void submitQuery(String query) {
    _query = query;
    _showSuggestions = false;
    search(query);
  }

  void selectSuggestion(String suggestion) {
    _query = suggestion;
    _showSuggestions = false;
    search(suggestion);
  }

  void clearSearch() {
    _query = '';
    _showSuggestions = true;
    _state = const Idle();
    notifyListeners();
  }

  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  Future<void> search(String query) async {
    _query = query;
    _showSuggestions = false;
    _state = const Loading();
    notifyListeners();

    final result = await _repository.search(
      query: query,
      type: _typeFilter,
      category: _categoryFilter,
    );

    _state = switch (result) {
      ResultSuccess(data: final list) => Success(list),
      FailureResult(failure: final f) => Error(message: f.message, retryable: true),
    };
    notifyListeners();
  }

  void setTypeFilter(ListingType? t) { _typeFilter = t; search(_query); }
  void setCategoryFilter(String? c) { _categoryFilter = c; search(_query); }

  void goToItem(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
  void goToListing(BuildContext context, String id) => context.push('${AppPaths.listingDetail}/$id');
}
