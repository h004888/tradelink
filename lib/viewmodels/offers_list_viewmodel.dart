import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../models/offer_model.dart';
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
}
