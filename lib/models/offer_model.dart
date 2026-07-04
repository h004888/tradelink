enum OfferType { buy, trade }

class Offer {
  final String id;
  final String listingId;
  final String buyerId;
  final double? price;
  final String? tradeItemDescription;
  final OfferType type;
  final String message;
  final DateTime createdAt;

  const Offer({
    required this.id, required this.listingId, required this.buyerId,
    this.price, this.tradeItemDescription, required this.type,
    required this.message, required this.createdAt,
  });
}
