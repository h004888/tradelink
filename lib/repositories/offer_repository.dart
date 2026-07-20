import '../core/api_client.dart';
import '../core/result.dart';
import '../models/offer_model.dart';
import '../models/transaction_model.dart';

class OfferRespondResult {
  final Offer offer;
  final Transaction? transaction;
  const OfferRespondResult({required this.offer, this.transaction});
}

class OfferRepository {
  final _api = ApiClient.instance;

  Future<Result<Offer>> create({
    required String listingId,
    required OfferType type,
    required String message,
    double? price,
    String? tradeItemDescription,
    double? cashTopUp,
  }) async {
    final res = await _api.post('/offers', body: {
      'listingId': listingId,
      'type': type == OfferType.trade ? 'trade' : 'buy',
      'message': message,
      'price': ?price,
      if (tradeItemDescription != null && tradeItemDescription.isNotEmpty)
        'tradeItemDescription': tradeItemDescription,
      'cashTopUp': ?cashTopUp,
    });
    return switch (res) {
      ResultSuccess(data: final d) =>
        ResultSuccess<Offer>(Offer.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Offer>(f),
    };
  }

  /// Seller chấp nhận/từ chối 1 offer. Chấp nhận → backend tạo luôn Transaction.
  Future<Result<OfferRespondResult>> respond(String offerId, bool accept) async {
    final res = await _api.patch('/offers/$offerId/respond', body: {
      'action': accept ? 'accept' : 'reject',
    });
    return switch (res) {
      ResultSuccess(data: final d) => () {
          final data = d['data'] as Map<String, dynamic>;
          final offer = Offer.fromJson(data['offer'] as Map<String, dynamic>);
          final txJson = data['transaction'] as Map<String, dynamic>?;
          return ResultSuccess<OfferRespondResult>(OfferRespondResult(
            offer: offer,
            transaction: txJson != null ? Transaction.fromJson(txJson) : null,
          ));
        }(),
      FailureResult(failure: final f) => FailureResult<OfferRespondResult>(f),
    };
  }

  Future<Result<List<Offer>>> getSentOffers() async {
    final me = await _api.get('/auth/me');
    if (me is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<Offer>>(me.failure);
    }
    final meSuccess = me as ResultSuccess<Map<String, dynamic>>;
    final userId = (meSuccess.data['data'] as Map)['_id'] as String;
    final res = await _api.get('/offers', query: {'buyerId': userId});
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<Offer>>(res.failure);
    }
    final resSuccess = res as ResultSuccess<Map<String, dynamic>>;
    final list = (resSuccess.data['data'] as List? ?? []);
    return ResultSuccess<List<Offer>>(
      list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Result<List<Offer>>> getReceivedOffers() async {
    final res = await _api.get('/offers', query: {'scope': 'received'});
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<Offer>>(res.failure);
    }
    final resSuccess = res as ResultSuccess<Map<String, dynamic>>;
    final list = (resSuccess.data['data'] as List? ?? []);
    return ResultSuccess<List<Offer>>(
      list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
