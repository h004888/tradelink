import 'package:flutter/material.dart';
import '../core/ui_state.dart';
import '../core/result.dart';
import '../models/offer_model.dart';
import '../repositories/offer_repository.dart';

class SendOfferViewModel extends ChangeNotifier {
  final String listingId;
  final OfferRepository _repository = OfferRepository();

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  double? _price;
  double? get price => _price;
  String _message = '';
  String get message => _message;
  OfferType _type = OfferType.buy;
  OfferType get type => _type;
  String _tradeItemDescription = '';
  String get tradeItemDescription => _tradeItemDescription;
  double? _cashTopUp;
  double? get cashTopUp => _cashTopUp;

  SendOfferViewModel({required this.listingId});

  void setPrice(String v) { _price = double.tryParse(v); notifyListeners(); }
  void setMessage(String v) { _message = v; }
  void setType(OfferType t) { _type = t; notifyListeners(); }
  void setTradeItemDescription(String v) { _tradeItemDescription = v; }
  void setCashTopUp(String v) { _cashTopUp = double.tryParse(v); }

  Future<bool> submit() async {
    if (_type == OfferType.buy && _price == null) {
      _state = const Error(message: 'Vui lòng nhập giá bạn đề nghị');
      notifyListeners();
      return false;
    }
    if (_type == OfferType.trade && _tradeItemDescription.trim().isEmpty) {
      _state = const Error(message: 'Vui lòng mô tả món đồ bạn muốn đổi');
      notifyListeners();
      return false;
    }

    _state = const Loading();
    notifyListeners();

    final res = await _repository.create(
      listingId: listingId,
      type: _type,
      message: _message,
      price: _type == OfferType.buy ? _price : null,
      tradeItemDescription: _type == OfferType.trade ? _tradeItemDescription : null,
      cashTopUp: _type == OfferType.trade ? _cashTopUp : null,
    );

    switch (res) {
      case ResultSuccess():
        _state = const Success(null);
        notifyListeners();
        return true;
      case FailureResult(failure: final f):
        _state = Error(message: f.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
