import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';

class CategoryItem {
  final String id;
  final String name;
  final int order;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.order,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// ViewModel cho danh sách danh mục trên Home.
class HomeCategoryViewModel extends ChangeNotifier {
  final _api = ApiClient.instance;

  UiState<List<CategoryItem>> _state = const Loading();
  UiState<List<CategoryItem>> get state => _state;

  /// Danh mục fallback khi API lỗi
  static const List<CategoryItem> fallbackCategories = [
    CategoryItem(id: 'cat_0', name: 'Điện thoại', order: 0),
    CategoryItem(id: 'cat_1', name: 'Laptop', order: 1),
    CategoryItem(id: 'cat_2', name: 'Xe cộ', order: 2),
    CategoryItem(id: 'cat_3', name: 'Thời trang', order: 3),
    CategoryItem(id: 'cat_4', name: 'Điện tử', order: 4),
    CategoryItem(id: 'cat_5', name: 'Phụ kiện', order: 5),
    CategoryItem(id: 'cat_6', name: 'Đồ gia dụng', order: 6),
    CategoryItem(id: 'cat_7', name: 'Khác', order: 7),
  ];

  HomeCategoryViewModel() { load(); }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    try {
      final res = await _api.get('/search/categories');
      if (res is ResultSuccess<Map<String, dynamic>>) {
        final list = ((res.data['data'] as List?) ?? [])
            .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _state = list.isNotEmpty ? Success(list) : Success(fallbackCategories);
      } else {
        _state = Success(fallbackCategories);
      }
    } catch (_) {
      _state = Success(fallbackCategories);
    }
    notifyListeners();
  }
}
