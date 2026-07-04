import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/core/failure.dart';
import 'package:tradelink/models/listing_model.dart';
import 'package:tradelink/repositories/listing_repository.dart';

void main() {
  group('ListingRepository', () {
    late ListingRepository repo;

    setUp(() => repo = ListingRepository());

    test('getMyListings returns listings for user-001', () async {
      final result = await repo.getMyListings();
      expect(result, isA<ResultSuccess<List<Listing>>>());
      final listings = (result as ResultSuccess).data;
      expect(listings.length, greaterThan(0));
      expect(listings.every((l) => l.sellerId == 'user-001'), true);
    });

    test('getMyListings filtered by draft returns only drafts', () async {
      final result = await repo.getMyListings(filter: ListingStatus.draft);
      final listings = (result as ResultSuccess).data;
      expect(listings.every((l) => l.status == ListingStatus.draft), true);
    });

    test('getListingById returns correct listing', () async {
      final result = await repo.getListingById('lst-001');
      expect(result, isA<ResultSuccess<Listing>>());
      final listing = (result as ResultSuccess).data;
      expect(listing.title, 'Sony A7IV Body');
      expect(listing.views, 245);
    });

    test('getListingById for non-existent returns NotFoundFailure', () async {
      final result = await repo.getListingById('nonexistent');
      expect(result, isA<FailureResult<Listing>>());
    });

    test('getDrafts returns only draft listings', () {
      final drafts = repo.getDrafts();
      expect(drafts.every((l) => l.status == ListingStatus.draft), true);
    });

    test('boostListing returns boosted listing', () async {
      final result = await repo.boostListing('lst-001', 3);
      expect(result, isA<ResultSuccess<Listing>>());
      final listing = (result as ResultSuccess).data;
      expect(listing.boostExpiry, isNotNull);
      expect(listing.isBoosted, true);
    });
  });
}
