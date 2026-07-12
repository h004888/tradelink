import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../models/listing_model.dart';

// ── Suggestion Models ──
class CategorySuggestion {
  final String id;
  final String name;
  final String icon;

  const CategorySuggestion({required this.id, required this.name, required this.icon});
}

class ProductSuggestion {
  final String id;
  final String title;
  final double? price;
  final String imageUrl;

  const ProductSuggestion({required this.id, required this.title, this.price, required this.imageUrl});
}

class SearchSuggestions {
  final List<CategorySuggestion> categories;
  final List<ProductSuggestion> products;

  const SearchSuggestions({required this.categories, required this.products});
}

class SearchRepository {
  final _api = ApiClient.instance;

  Listing _fromJson(Map<String, dynamic> j) => Listing(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble(),
        imageUrls: (j['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        category: j['category'] as String? ?? '',
        categoryId: j['categoryId']?.toString(),
        sellerId: j['sellerId']?.toString() ?? '',
        sellerName: j['sellerName'] as String? ?? '',
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Future<Result<List<Listing>>> search({
    String query = '',
    ListingType? type,
    String? category,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final q = <String, String>{};
    if (query.isNotEmpty) q['q'] = query;
    if (type != null) q['type'] = type.name;
    if (category != null) q['category'] = category;
    if (categoryId != null) q['categoryId'] = categoryId;
    if (minPrice != null) q['minPrice'] = minPrice.toString();
    if (maxPrice != null) q['maxPrice'] = maxPrice.toString();

    final res = await _api.get('/search', query: q.isEmpty ? null : q);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Listing>>(
          ((d['listings'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Listing>>(f),
    };
  }

  Future<Result<SearchSuggestions>> getSuggestions(String query) async {
    if (query.length < 2) {
      return const ResultSuccess(SearchSuggestions(categories: [], products: []));
    }

    final res = await _api.get('/search/suggestions', query: {'q': query});
    if (res.isFailure) return FailureResult<SearchSuggestions>((res as FailureResult).failure);

    try {
      final data = (res as ResultSuccess<Map<String, dynamic>>).data['data'];
      return ResultSuccess(SearchSuggestions(
        categories: ((data['categories'] as List?) ?? []).map((e) => CategorySuggestion(
          id: e['_id']?.toString() ?? '',
          name: e['name'] as String? ?? '',
          icon: e['icon'] as String? ?? 'category',
        )).toList(),
        products: ((data['products'] as List?) ?? []).map((e) => ProductSuggestion(
          id: e['_id']?.toString() ?? '',
          title: e['title'] as String? ?? '',
          price: (e['price'] as num?)?.toDouble(),
          imageUrl: ((e['imageUrls'] as List?) ?? []).isNotEmpty ? e['imageUrls'][0].toString() : '',
        )).toList(),
      ));
    } catch (e) {
      return FailureResult(UnknownFailure(message: 'Lỗi xử lý suggestions: $e'));
    }
  }
}
