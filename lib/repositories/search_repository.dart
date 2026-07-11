import '../core/api_client.dart';
import '../core/result.dart';
import '../models/listing_model.dart';

class SearchRepository {
  final _api = ApiClient.instance;

  Listing _fromJson(Map<String, dynamic> j) => Listing(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble(),
        imageUrls: (j['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        category: j['category'] as String? ?? '',
        sellerId: j['sellerId']?.toString() ?? '',
        sellerName: j['sellerName'] as String? ?? '',
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Future<Result<List<Listing>>> search({
    String query = '',
    ListingType? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final q = <String, String>{};
    if (query.isNotEmpty) q['q'] = query;
    if (type != null) q['type'] = type.name;
    if (category != null) q['category'] = category;
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
}
