import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../models/offer_model.dart';
import '../../models/transaction_model.dart';
import '../../repositories/offer_repository.dart';

enum OffersScope { sent, received }

class OffersListViewModel extends ChangeNotifier {
  final OfferRepository _repository = OfferRepository();

  OffersScope _scope = OffersScope.sent;
  OffersScope get scope => _scope;

  final List<Offer> _items = [];
  List<Offer> get items => _items;
  bool _loading = false;
  bool get isLoading => _loading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Set<String> _respondingIds = {};
  bool isResponding(String offerId) => _respondingIds.contains(offerId);
  String? _respondError;
  String? get respondError => _respondError;

  OffersListViewModel({OffersScope scope = OffersScope.sent}) {
    _scope = scope;
    load();
  }

  void switchScope(OffersScope scope) {
    if (scope == _scope) return;
    _scope = scope;
    _items.clear();
    load();
  }

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    final res = _scope == OffersScope.sent
        ? await _repository.getSentOffers()
        : await _repository.getReceivedOffers();
    switch (res) {
      case ResultSuccess<List<Offer>>():
        _items
          ..clear()
          ..addAll(res.data);
      case FailureResult<List<Offer>>():
        _errorMessage = (res).failure.message;
    }
    _loading = false;
    notifyListeners();
  }

  /// Seller chấp nhận/từ chối 1 offer đã nhận. Trả về Transaction nếu chấp nhận
  /// thành công (để view điều hướng sang màn theo dõi tương ứng).
  Future<Transaction?> respond(String offerId, bool accept) async {
    _respondingIds.add(offerId);
    _respondError = null;
    notifyListeners();

    final res = await _repository.respond(offerId, accept);
    _respondingIds.remove(offerId);

    switch (res) {
      case ResultSuccess<OfferRespondResult>(:final data):
        final idx = _items.indexWhere((o) => o.id == offerId);
        if (idx != -1) _items[idx] = data.offer;
        notifyListeners();
        return data.transaction;
      case FailureResult<OfferRespondResult>(:final failure):
        _respondError = failure.message;
        notifyListeners();
        return null;
    }
  }
}
