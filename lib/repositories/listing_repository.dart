import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../models/filter_model.dart';
import '../models/listing_model.dart';
import '../models/seller_stats.dart';

class HomeData {
  final List<Listing> featured;
  final List<Listing> newest;
  final List<Listing> popular;
  final List<String> categories;
  final List<TopSellerInfo> topSellers;
  final bool hasMore;
  final int page;

  const HomeData({
    required this.featured,
    required this.newest,
    required this.popular,
    required this.categories,
    required this.topSellers,
    this.hasMore = false,
    this.page = 1,
  });
}

class FeedData {
  final List<Listing> listings;
  final List<String> categories;
  final bool hasMore;
  final int page;

  const FeedData({
    required this.listings,
    required this.categories,
    this.hasMore = false,
    this.page = 1,
  });
}

class TopSellerInfo {
  final String sellerId;
  final String sellerName;
  final int totalListings;
  final int totalViews;

  const TopSellerInfo({
    required this.sellerId,
    required this.sellerName,
    required this.totalListings,
    required this.totalViews,
  });

  factory TopSellerInfo.fromJson(Map<String, dynamic> json) {
    return TopSellerInfo(
      sellerId: json['_id']?.toString() ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
    );
  }
}

class ListingRepository {
  final _api = ApiClient.instance;

  Listing _fromJson(Map<String, dynamic> j) => Listing(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble(),
        exchangeFor: j['exchangeFor'] as String?,
        imageUrls: (j['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        category: j['category'] as String? ?? '',
        categoryName: j['categoryName'] as String?,
        categoryId: j['categoryId']?.toString(),
        condition: _parseCondition(j['condition'] as String?),
        type: _parseType(j['type'] as String?),
        status: _parseStatus(j['status'] as String?),
        sellerId: j['sellerId']?.toString() ?? '',
        sellerName: j['sellerName'] as String? ?? '',
        location: j['location'] as String?,
        views: (j['views'] as num?)?.toInt() ?? 0,
        interests: (j['interests'] as num?)?.toInt() ?? 0,
        saves: (j['saves'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: j['updatedAt'] != null ? DateTime.tryParse(j['updatedAt'].toString()) : null,
        boostExpiry: j['boostExpiry'] != null ? DateTime.tryParse(j['boostExpiry'].toString()) : null,
      );

  Future<Result<List<Listing>>> getMyListings({ListingStatus? filter}) async {
    final query = <String, String>{};
    if (filter != null) query['status'] = filter.name;
    final res = await _api.get('/listings/my', query: query);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Listing>>(
          ((d['data'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Listing>>(f),
    };
  }

  Future<Result<Listing>> getListingById(String id) async {
    final res = await _api.get('/listings/$id');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<SellerStats>> getSellerStats(String sellerId) async {
    final res = await _api.get('/users/$sellerId/stats');
    if (res.isFailure) return FailureResult<SellerStats>((res as FailureResult).failure);
    try {
      final data = (res as ResultSuccess<Map<String, dynamic>>).data['data'];
      return ResultSuccess(SellerStats.fromJson(data));
    } catch (e) {
      return FailureResult(UnknownFailure(message: 'Lỗi tải thông tin người bán'));
    }
  }

  Future<Result<Listing>> createListing(Listing listing) async {
    final res = await _api.post('/listings', body: {
      'title': listing.title,
      'description': listing.description,
      'price': listing.price,
      'exchangeFor': listing.exchangeFor,
      'imageUrls': listing.imageUrls,
      'category': listing.category,
      'categoryId': listing.categoryId,
      'condition': listing.condition.name.replaceAll('_', ''),
      'type': listing.type.name,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<Listing>> updateListing(Listing listing) async {
    final res = await _api.put('/listings/${listing.id}', body: {
      'title': listing.title,
      'description': listing.description,
      'price': listing.price,
      'exchangeFor': listing.exchangeFor,
      'imageUrls': listing.imageUrls,
      'category': listing.category,
      'categoryId': listing.categoryId,
      'condition': listing.condition.name.replaceAll('_', ''),
      'type': listing.type.name,
      'status': listing.status.name,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<List<Listing>>> getFeatured({int limit = 10}) async {
    final res = await _api.get('/home', query: limit != 10 ? {'limit': limit.toString()} : null);
    if (res.isFailure) return FailureResult<List<Listing>>((res as FailureResult<Map<String, dynamic>>).failure);
    final d = (res as ResultSuccess<Map<String, dynamic>>).data;
    final data = d['data'] as Map<String, dynamic>;
    final list = ((data['featured'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    return ResultSuccess<List<Listing>>(list);
  }

  /// Load tất cả section cho Home screen
  Future<Result<HomeData>> getHomeData({int page = 1}) async {
    final res = await _api.get('/home', query: {'page': page.toString()});
    if (res.isFailure) return FailureResult<HomeData>((res as FailureResult<Map<String, dynamic>>).failure);
    try {
      final d = (res as ResultSuccess<Map<String, dynamic>>).data;
      final data = d['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const FailureResult(NetworkFailure(message: 'Dữ liệu home không hợp lệ'));
      }
      return ResultSuccess<HomeData>(HomeData(
        featured: ((data['featured'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        newest: ((data['newest'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        popular: ((data['popular'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        categories: ((data['categories'] as List?) ?? []).map((e) => e.toString()).toList(),
        topSellers: ((data['topSellers'] as List?) ?? []).map((e) => TopSellerInfo.fromJson(e as Map<String, dynamic>)).toList(),
        hasMore: data['hasMore'] ?? false,
        page: data['page'] ?? page,
      ));
    } catch (e) {
      return FailureResult(UnknownFailure(message: 'Lỗi xử lý dữ liệu home: $e'));
    }
  }

  /// Load feed — tất cả sản phẩm, infinite scroll
  Future<Result<FeedData>> getFeed({int page = 1, FeedFilter? filter}) async {
    final query = {'page': page.toString()};
    if (filter != null) query.addAll(filter.toQuery());

    final res = await _api.get('/feed', query: query);
    if (res.isFailure) return FailureResult<FeedData>((res as FailureResult<Map<String, dynamic>>).failure);
    try {
      final d = (res as ResultSuccess<Map<String, dynamic>>).data;
      final data = d['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const FailureResult(NetworkFailure(message: 'Dữ liệu feed không hợp lệ'));
      }
      return ResultSuccess<FeedData>(FeedData(
        listings: ((data['listings'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        categories: ((data['categories'] as List?) ?? []).map((e) => e.toString()).toList(),
        hasMore: data['hasMore'] ?? false,
        page: data['page'] ?? page,
      ));
    } catch (e) {
      return FailureResult(UnknownFailure(message: 'Lỗi xử lý feed: $e'));
    }
  }

  /// Helper: GET /listings với sort param — parse response chung
  Future<Result<List<Listing>>> _getListingsBySort(String sort, {int limit = 10}) async {
    final res = await _api.get('/listings', query: {'sort': sort, 'limit': limit.toString()});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Listing>>(
          ((d['listings'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Listing>>(f),
    };
  }

  /// Featured listings — boosted + nhiều views nhất
  Future<Result<List<Listing>>> getFeaturedListings({int limit = 10}) =>
      _getListingsBySort('boosted', limit: limit);

  /// Newest listings — mới đăng nhất
  Future<Result<List<Listing>>> getNewestListings({int limit = 10}) =>
      _getListingsBySort('newest', limit: limit);

  /// Popular listings — nhiều saves + views nhất
  Future<Result<List<Listing>>> getPopularListings({int limit = 10}) =>
      _getListingsBySort('popular', limit: limit);

  /// Top sellers — từ user service
  Future<Result<List<TopSellerInfo>>> getTopSellers() async {
    final res = await _api.get('/users/top-sellers');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<TopSellerInfo>>(
          ((d['data'] as List?) ?? []).map((e) => TopSellerInfo.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<TopSellerInfo>>(f),
    };
  }

  Future<Result<List<Listing>>> getAllListings({
    String? status,
    String? type,
    String? category,
    String? categoryId,
    int? page,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    if (category != null) query['category'] = category;
    if (categoryId != null) query['categoryId'] = categoryId;
    if (page != null) query['page'] = page.toString();
    if (limit != null) query['limit'] = limit.toString();
    final res = await _api.get('/listings', query: query.isEmpty ? null : query);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<Listing>>(
          ((d['listings'] as List?) ?? []).map((e) => _fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<Listing>>(f),
    };
  }

  Future<Result<void>> deleteListing(String id) async {
    final res = await _api.delete('/listings/$id');
    return switch (res) {
      ResultSuccess() => ResultSuccess<void>(null),
      FailureResult(failure: final f) => FailureResult<void>(f),
    };
  }

  Future<Result<Listing>> hideListing(String id) async {
    final res = await _api.put('/listings/$id', body: {'status': 'hidden'});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<Listing>> unhideListing(String id) async {
    final res = await _api.put('/listings/$id', body: {'status': 'active'});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<Listing>> boostListing(String id, int days) async {
    final res = await _api.post('/listings/$id/boost', body: {'days': days});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Listing>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Listing>(f),
    };
  }

  Future<Result<List<Listing>>> getDrafts() async => getMyListings(filter: ListingStatus.draft);
}

ItemCondition _parseCondition(String? s) => switch (s) {
      'new' => ItemCondition.new_,
      'likeNew' => ItemCondition.likeNew,
      _ => ItemCondition.used,
    };

ListingType _parseType(String? s) => switch (s) {
      'trade' => ListingType.trade,
      'both' => ListingType.both,
      _ => ListingType.sale,
    };

ListingStatus _parseStatus(String? s) => switch (s) {
      'sold' => ListingStatus.sold,
      'hidden' => ListingStatus.hidden,
      'draft' => ListingStatus.draft,
      _ => ListingStatus.active,
    };
