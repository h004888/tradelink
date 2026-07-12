import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';
import '../../utils/constants.dart';

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

  String? _categoryFilter;

  // ── Suggestions state ──
  SearchSuggestions? _suggestions;
  SearchSuggestions? get suggestions => _suggestions;

  bool _showSuggestions = true;
  bool get showSuggestions => _showSuggestions;

  Timer? _debounce;

  // ── Recent searches ──
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    _recentSearches = ['iPhone 15', 'Laptop Dell', 'Xe máy'];
    notifyListeners();
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
    notifyListeners();
  }

  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  void clearAllRecentSearches() {
    _recentSearches.clear();
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
      category: _categoryFilter,
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

  void setCategoryFilter(String? c) {
    _categoryFilter = c;
    if (_query.isNotEmpty) search(_query);
    notifyListeners();
  }

  // ── Navigation ──
  void goToItem(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
  void goToListing(BuildContext context, String id) => context.push('${AppPaths.listingDetail}/$id');
}
