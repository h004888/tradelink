enum ListingType { sale, trade, both }

enum ListingStatus { active, sold, hidden, draft }

enum ItemCondition { new_, likeNew, used }

class Listing {
  final String id;
  final String title;
  final String description;
  final double? price;
  final List<String> imageUrls;
  final String category;
  final ItemCondition condition;
  final ListingType type;
  final ListingStatus status;
  final String sellerId;
  final String sellerName;
  final int views;
  final int interests;
  final int saves;
  final DateTime createdAt;
  final DateTime? boostExpiry;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.imageUrls = const [],
    required this.category,
    this.condition = ItemCondition.used,
    this.type = ListingType.sale,
    this.status = ListingStatus.active,
    required this.sellerId,
    required this.sellerName,
    this.views = 0,
    this.interests = 0,
    this.saves = 0,
    required this.createdAt,
    this.boostExpiry,
  });

  Listing copyWith({
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? category,
    ItemCondition? condition,
    ListingType? type,
    ListingStatus? status,
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
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      type: type ?? this.type,
      status: status ?? this.status,
      sellerId: sellerId,
      sellerName: sellerName,
      views: views ?? this.views,
      interests: interests ?? this.interests,
      saves: saves ?? this.saves,
      createdAt: createdAt,
      boostExpiry: boostExpiry ?? this.boostExpiry,
    );
  }

  String get priceFormatted => price != null ? '${price!.toStringAsFixed(0)} VNĐ' : 'Trao đổi';

  bool get isBoosted => boostExpiry != null && boostExpiry!.isAfter(DateTime.now());

  int get completionPercent {
    int filled = 0;
    if (title.isNotEmpty) filled++;
    if (description.isNotEmpty) filled++;
    if (imageUrls.isNotEmpty) filled++;
    if (price != null || type != ListingType.sale) filled++;
    if (category.isNotEmpty) filled++;
    return (filled / 5 * 100).round();
  }
}
