import '../../core/result.dart';
import '../../models/listing_model.dart';

class SearchRepository {
  final List<Listing> _allListings = [
    Listing(id: 's1', title: 'iPhone 15 Pro Max', description: 'Like new', price: 28000000, imageUrls: [], category: 'Điện thoại', condition: ItemCondition.likeNew, type: ListingType.sale, sellerId: 'u1', sellerName: 'A', createdAt: DateTime.now()),
    Listing(id: 's2', title: 'MacBook Air M3', description: 'Còn bảo hành', price: 22000000, imageUrls: [], category: 'Điện tử', condition: ItemCondition.likeNew, type: ListingType.sale, sellerId: 'u2', sellerName: 'B', createdAt: DateTime.now()),
    Listing(id: 's3', title: 'Samsung S24 Ultra', description: 'Đổi lấy iPhone', price: null, imageUrls: [], category: 'Điện thoại', condition: ItemCondition.new_, type: ListingType.trade, sellerId: 'u3', sellerName: 'C', createdAt: DateTime.now()),
    Listing(id: 's4', title: 'Bàn phím cơ Keychron', description: 'Switch Brown', price: 1200000, imageUrls: [], category: 'Phụ kiện', condition: ItemCondition.used, type: ListingType.both, sellerId: 'u4', sellerName: 'D', createdAt: DateTime.now()),
    Listing(id: 's5', title: 'Xe đạp Trek FX3', description: 'Mới 99%', price: 15000000, imageUrls: [], category: 'Xe cộ', condition: ItemCondition.likeNew, type: ListingType.sale, sellerId: 'u1', sellerName: 'A', createdAt: DateTime.now()),
    Listing(id: 's6', title: 'Đồng hồ Casio G-Shock', description: 'Limited edition', price: 3500000, imageUrls: [], category: 'Thời trang', condition: ItemCondition.new_, type: ListingType.sale, sellerId: 'u5', sellerName: 'E', createdAt: DateTime.now()),
  ];

  Future<Result<List<Listing>>> search({
    String query = '',
    ListingType? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var results = _allListings.toList();

    if (query.isNotEmpty) {
      results = results.where((l) => l.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (type != null) {
      results = results.where((l) => l.type == type || l.type == ListingType.both).toList();
    }
    if (category != null) {
      results = results.where((l) => l.category == category).toList();
    }
    if (minPrice != null) {
      results = results.where((l) => l.price != null && l.price! >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((l) => l.price != null && l.price! <= maxPrice).toList();
    }
    return ResultSuccess(results);
  }
}
