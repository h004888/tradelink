/// Public profile of a seller — visible to all users (including Guest).
class PublicSellerProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final int completedTransactions;
  final double successRate;
  final double rating;
  final String? responseTime;
  final double? shipOnTimeRate;
  final DateTime memberSince;
  final int activeListings;
  final List<SellerListingPreview> listings;

  const PublicSellerProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
    this.completedTransactions = 0,
    this.successRate = 100,
    this.rating = 0,
    this.responseTime,
    this.shipOnTimeRate,
    required this.memberSince,
    this.activeListings = 0,
    this.listings = const [],
  });

  factory PublicSellerProfile.fromJson(Map<String, dynamic> json) {
    return PublicSellerProfile(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      completedTransactions: (json['completedTransactions'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 100,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      responseTime: json['responseTime'] as String?,
      shipOnTimeRate: (json['shipOnTimeRate'] as num?)?.toDouble(),
      memberSince: DateTime.tryParse(json['memberSince']?.toString() ?? '') ?? DateTime.now(),
      activeListings: (json['activeListings'] as num?)?.toInt() ?? 0,
      listings: (json['listings'] as List<dynamic>?)
              ?.map((e) => SellerListingPreview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SellerListingPreview {
  final String id;
  final String title;
  final String price;
  final String priceFormatted;
  final String? imageUrl;

  const SellerListingPreview({
    required this.id,
    required this.title,
    required this.price,
    required this.priceFormatted,
    this.imageUrl,
  });

  factory SellerListingPreview.fromJson(Map<String, dynamic> json) {
    return SellerListingPreview(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: json['price']?.toString() ?? '0',
      priceFormatted: json['priceFormatted'] as String? ?? '0',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
