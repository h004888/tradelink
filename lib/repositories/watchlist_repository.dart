import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../models/listing_model.dart';

class WatchlistRepository {
  final _api = ApiClient.instance;

  Listing _fromListingJson(Map<String, dynamic> j) {
    return Listing(
      id: j['_id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      price: (j['price'] as num?)?.toDouble(),
      imageUrls: (j['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      category: j['category']?.toString() ?? '',
      condition: _condFromString(j['condition']?.toString()),
      type: _typeFromString(j['type']?.toString()),
      status: ListingStatus.active,
      sellerId: j['sellerId']?.toString() ?? '',
      sellerName: j['sellerName']?.toString() ?? '',
      views: (j['views'] as num?)?.toInt() ?? 0,
      interests: 0,
      saves: (j['saves'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      boostExpiry: j['boostExpiry'] != null ? DateTime.tryParse(j['boostExpiry'].toString()) : null,
    );
  }

  Future<Result<bool>> isSaved(String listingId) async {
    final res = await _api.get('/watchlist/check/$listingId');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<bool>(res.failure);
    }
    final success = res as ResultSuccess<Map<String, dynamic>>;
    final data = success.data['data'] as Map?;
    final saved = (data?['saved'] as bool?) ?? false;
    return ResultSuccess<bool>(saved);
  }

  /// Toggle trạng thái lưu: nếu đang lưu thì bỏ, ngược lại thì lưu.
  Future<Result<bool>> toggleSave(String listingId, bool currentlySaved) async {
    return currentlySaved ? await unsave(listingId) : await save(listingId);
  }

  Future<Result<bool>> save(String listingId) async {
    final res = await _api.post('/watchlist', body: {'listingId': listingId});
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  Future<Result<bool>> unsave(String listingId) async {
    final res = await _api.delete('/watchlist/$listingId');
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  Future<Result<List<Listing>>> getAll() async {
    final res = await _api.get('/watchlist');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Listing>>(
          ((d['data'] as List?) ?? [])
              .map((e) => _fromListingJson(((e as Map<String, dynamic>)['listingId'] as Map<String, dynamic>? ?? {}) as Map<String, dynamic>))
              .toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Listing>>(f),
    };
  }

  ItemCondition _condFromString(String? s) => switch (s) {
        'new' => ItemCondition.new_,
        'likeNew' => ItemCondition.likeNew,
        _ => ItemCondition.used,
      };

  ListingType _typeFromString(String? s) => switch (s) {
        'trade' => ListingType.trade,
        'both' => ListingType.both,
        _ => ListingType.sale,
      };
}
