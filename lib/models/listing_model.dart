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
