import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';
import '../../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  UiState<List<Listing>> _featured = const Loading();
  UiState<List<Listing>> get featured => _featured;

  static const List<String> categories = ['Tất cả', 'Điện tử', 'Điện thoại', 'Phụ kiện', 'Xe cộ', 'Thời trang'];
  int _selectedCategory = 0;
  int get selectedCategory => _selectedCategory;

  HomeViewModel() { load(); }

  Future<void> load() async {
    _featured = const Loading(); notifyListeners();
    final result = await _repository.search();
    switch (result) {
      case ResultSuccess(data: final list): _featured = Success(list);
      case FailureResult(failure: final f): _featured = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  void selectCategory(int i) { _selectedCategory = i; notifyListeners(); }

  void goToSearch(BuildContext context) => context.push(AppPaths.search);
  void goToItemDetail(BuildContext context, String id) => context.push('${AppPaths.itemDetail}/$id');
}
