import '../../core/failure.dart';
import '../../core/result.dart';
import '../../models/listing_model.dart';

class ListingRepository {
  final List<Listing> _mockListings = [
    Listing(
      id: 'lst-001', title: 'Sony A7IV Body', description: 'Máy ảnh mirrorless full-frame, mới 99%, shutter 2000', price: 45000000,
      imageUrls: ['img1.jpg'], category: 'Điện tử', condition: ItemCondition.likeNew, type: ListingType.sale,
      status: ListingStatus.active, sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi',
      views: 245, interests: 12, saves: 8, createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Listing(
      id: 'lst-002', title: 'iPhone 15 Pro Max 256GB', description: 'Đổi lấy Samsung S24 Ultra hoặc MacBook', price: null,
      imageUrls: ['img2.jpg'], category: 'Điện thoại', condition: ItemCondition.likeNew, type: ListingType.trade,
      status: ListingStatus.active, sellerId: 'user-002', sellerName: 'Trần Văn B',
      views: 890, interests: 34, saves: 15, createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Listing(
      id: 'lst-003', title: 'Bàn phím cơ Keychron K8', description: 'Switch Gateron Brown, fullsize, còn box', price: 1200000,
      imageUrls: ['img3.jpg'], category: 'Phụ kiện', condition: ItemCondition.used, type: ListingType.both,
      status: ListingStatus.draft, sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi',
      views: 0, interests: 0, saves: 0, createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Listing(
      id: 'lst-004', title: 'Logitech MX Master 3S', description: 'Chuột không dây, còn bảo hành 6 tháng', price: 1800000,
      imageUrls: ['img4.jpg'], category: 'Phụ kiện', condition: ItemCondition.likeNew, type: ListingType.sale,
      status: ListingStatus.sold, sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi',
      views: 567, interests: 23, saves: 10, createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  Future<Result<List<Listing>>> getMyListings({ListingStatus? filter}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var list = _mockListings.where((l) => l.sellerId == 'user-001').toList();
    if (filter != null) list = list.where((l) => l.status == filter).toList();
    return ResultSuccess(list);
  }

  Future<Result<Listing>> getListingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final listing = _mockListings.where((l) => l.id == id).firstOrNull;
    if (listing == null) return FailureResult(const NotFoundFailure(message: 'Không tìm thấy tin đăng'));
    return ResultSuccess(listing);
  }

  Future<Result<Listing>> createListing(Listing listing) async {
    await Future.delayed(const Duration(seconds: 1));
    return ResultSuccess(listing);
  }

  Future<Result<Listing>> updateListing(Listing listing) async {
    await Future.delayed(const Duration(seconds: 1));
    return ResultSuccess(listing);
  }

  Future<Result<void>> deleteListing(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const ResultSuccess(null);
  }

  Future<Result<Listing>> boostListing(String id, int days) async {
    await Future.delayed(const Duration(seconds: 1));
    final listing = _mockListings.firstWhere((l) => l.id == id);
    return ResultSuccess(listing.copyWith(boostExpiry: DateTime.now().add(Duration(days: days))));
  }

  List<Listing> getDrafts() {
    return _mockListings.where((l) => l.status == ListingStatus.draft).toList();
  }
}
