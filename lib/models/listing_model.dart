import '../utils/format.dart';

enum ListingType { sale, trade, both }

enum ListingStatus { active, sold, hidden, draft }

enum ItemCondition { new_, likeNew, used }

class Listing {
  final String id;
  final String title;
  final String description;
  final double? price;
  final List<String> imageUrls;
  final String? exchangeFor;
  final String category;
  final String? categoryName;
  final String? categoryId;
  final ItemCondition condition;
  final ListingType type;
  final ListingStatus status;
  final String sellerId;
  final String sellerName;
  final String? location;
  final int views;
  final int interests;
  final int saves;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? boostExpiry;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.exchangeFor,
    this.imageUrls = const [],
    required this.category,
    this.categoryName,
    this.categoryId,
    this.condition = ItemCondition.used,
    this.type = ListingType.sale,
    this.status = ListingStatus.active,
    required this.sellerId,
    required this.sellerName,
    this.location,
    this.views = 0,
    this.interests = 0,
    this.saves = 0,
    required this.createdAt,
    this.updatedAt,
    this.boostExpiry,
  });

  Listing copyWith({
    String? title,
    String? description,
    double? price,
    String? exchangeFor,
    List<String>? imageUrls,
    String? category,
    String? categoryName,
    ItemCondition? condition,
    ListingType? type,
    ListingStatus? status,
    String? location,
    int? views,
    int? interests,
    int? saves,
    DateTime? boostExpiry,
  }) {
    return Listing(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      exchangeFor: exchangeFor ?? this.exchangeFor,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? categoryId,
      condition: condition ?? this.condition,
      type: type ?? this.type,
      status: status ?? this.status,
      sellerId: sellerId,
      sellerName: sellerName,
      location: location ?? this.location,
      views: views ?? this.views,
      interests: interests ?? this.interests,
      saves: saves ?? this.saves,
      createdAt: createdAt,
      updatedAt: updatedAt ?? updatedAt,
      boostExpiry: boostExpiry ?? this.boostExpiry,
    );
  }

  /// Dùng để lưu snapshot xuống SQLite local (watchlist) — không phải contract API server.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'exchangeFor': exchangeFor,
      'category': category,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'condition': switch (condition) {
        ItemCondition.new_ => 'new',
        ItemCondition.likeNew => 'likeNew',
        ItemCondition.used => 'used',
      },
      'type': switch (type) {
        ListingType.trade => 'trade',
        ListingType.both => 'both',
        ListingType.sale => 'sale',
      },
      'status': switch (status) {
        ListingStatus.sold => 'sold',
        ListingStatus.hidden => 'hidden',
        ListingStatus.draft => 'draft',
        ListingStatus.active => 'active',
      },
      'sellerId': sellerId,
      'sellerName': sellerName,
      'location': location,
      'views': views,
      'interests': interests,
      'saves': saves,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'boostExpiry': boostExpiry?.toIso8601String(),
    };
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      exchangeFor: json['exchangeFor']?.toString(),
      imageUrls: (json['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      category: json['category']?.toString() ?? '',
      categoryName: json['categoryName']?.toString(),
      categoryId: json['categoryId']?.toString(),
      condition: switch (json['condition']?.toString()) {
        'new' => ItemCondition.new_,
        'likeNew' => ItemCondition.likeNew,
        _ => ItemCondition.used,
      },
      type: switch (json['type']?.toString()) {
        'trade' => ListingType.trade,
        'both' => ListingType.both,
        _ => ListingType.sale,
      },
      status: switch (json['status']?.toString()) {
        'sold' => ListingStatus.sold,
        'hidden' => ListingStatus.hidden,
        'draft' => ListingStatus.draft,
        _ => ListingStatus.active,
      },
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? '',
      location: json['location']?.toString(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      interests: (json['interests'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      boostExpiry: json['boostExpiry'] != null ? DateTime.tryParse(json['boostExpiry'].toString()) : null,
    );
  }

  String get priceFormatted => formatVnd(price);

  bool get isBoosted => boostExpiry != null && boostExpiry!.isAfter(DateTime.now());

  int get completionPercent {
    int filled = 0;
    if (title.isNotEmpty) filled++;
    if (description.isNotEmpty) filled++;
    if (imageUrls.isNotEmpty) filled++;
    
    bool hasPrice = price != null;
    bool hasExchange = exchangeFor != null && exchangeFor!.isNotEmpty;
    if ((type == ListingType.sale && hasPrice) || 
        (type == ListingType.trade && hasExchange) ||
        (type == ListingType.both && hasPrice && hasExchange)) {
      filled++;
    }
    
    if (category.isNotEmpty) filled++;
    return (filled / 5 * 100).round();
  }
}
