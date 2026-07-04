import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';
import '../../utils/constants.dart';

class SearchResultsViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  UiState<List<Listing>> _state = const Idle();
  UiState<List<Listing>> get state => _state;

  String _query = '';
  ListingType? _typeFilter;
  String? _categoryFilter;

  Future<void> search(String query) async {
    _query = query;
    _state = const Loading(); notifyListeners();
    final result = await _repository.search(query: query, type: _typeFilter, category: _categoryFilter);
    switch (result) {
      case ResultSuccess(data: final list): _state = Success(list);
      case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void setTypeFilter(ListingType? t) { _typeFilter = t; search(_query); }
  void setCategoryFilter(String? c) { _categoryFilter = c; search(_query); }

  void goToItem(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
}
