import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../models/offer_model.dart';

class OfferRepository {
  final _api = ApiClient.instance;

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
