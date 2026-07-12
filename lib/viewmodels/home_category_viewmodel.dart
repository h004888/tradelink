import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';

class CategoryItem {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final int order;

  const CategoryItem({
    required this.id,
    required this.name,
    this.slug = '',
    this.icon = 'grid_view_rounded',
    required this.order,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String? ?? 'grid_view_rounded',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// ViewModel cho danh sách danh mục trên Home.
class HomeCategoryViewModel extends ChangeNotifier {
  final _api = ApiClient.instance;

  UiState<List<CategoryItem>> _state = const Loading();
  UiState<List<CategoryItem>> get state => _state;

  HomeCategoryViewModel() { load(); }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    try {
      final res = await _api.get('/categories');
      if (res is ResultSuccess<Map<String, dynamic>>) {
        final list = ((res.data['data'] as List?) ?? [])
            .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _state = list.isNotEmpty
            ? Success(list)
            : const Error(message: 'Không có danh mục nào');
      } else {
        _state = Error(message: (res as FailureResult<Map<String, dynamic>>).failure.message, retryable: true);
      }
    } catch (e) {
      _state = Error(message: 'Lỗi tải danh mục: $e', retryable: true);
    }
    notifyListeners();
  }
}
