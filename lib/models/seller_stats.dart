class SellerStats {
  final String sellerId;
  final String sellerName;
  final double rating;
  final int totalTransactions;
  final int totalReviews;
  final String responseTime;

  const SellerStats({
    required this.sellerId,
    required this.sellerName,
    this.rating = 0,
    this.totalTransactions = 0,
    this.totalReviews = 0,
    this.responseTime = 'Chưa có',
  });

  factory SellerStats.fromJson(Map<String, dynamic> json) {
    return SellerStats(
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName'] as String? ?? 'Người bán',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      responseTime: json['responseTime'] as String? ?? 'Chưa có',
    );
  }

  String get ratingFormatted => rating > 0 ? rating.toStringAsFixed(1) : '0';
}
