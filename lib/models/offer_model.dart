enum OfferType { buy, trade }

class Offer {
  final String id;
  final String listingId;
  final String? listingTitle;
  final double? listingPrice;
  final String buyerId;
  final String? buyerName;
  final String? buyerPhone;
  final double? price;
  final String? tradeItemDescription;
  final OfferType type;
  final String message;
  final DateTime createdAt;

  const Offer({
    required this.id,
    required this.listingId,
    this.listingTitle,
    this.listingPrice,
    required this.buyerId,
    this.buyerName,
    this.buyerPhone,
    this.price,
    this.tradeItemDescription,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> j) {
    final listing = j['listingId'] is Map ? j['listingId'] as Map : null;
    final buyer = j['buyerId'] is Map ? j['buyerId'] as Map : null;
    return Offer(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      listingId: (listing?['_id'] ?? j['listingId'])?.toString() ?? '',
      listingTitle: listing?['title'] as String?,
      listingPrice: (listing?['price'] as num?)?.toDouble(),
      buyerId: (buyer?['_id'] ?? j['buyerId'])?.toString() ?? '',
      buyerName: buyer?['name'] as String?,
      buyerPhone: buyer?['phone'] as String?,
      price: (j['price'] as num?)?.toDouble(),
      tradeItemDescription: j['tradeItemDescription'] as String?,
      type: (j['type']?.toString() == 'trade') ? OfferType.trade : OfferType.buy,
      message: j['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
