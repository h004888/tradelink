import 'package:flutter/material.dart';
import '../../core/ui_state.dart';
import '../../models/offer_model.dart';

class SendOfferViewModel extends ChangeNotifier {
  final String listingId;

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;

  double? _price;
  double? get price => _price;
  String _message = '';
  String get message => _message;
  OfferType _type = OfferType.buy;
  OfferType get type => _type;

  SendOfferViewModel({required this.listingId});

  void setPrice(String v) { _price = double.tryParse(v); notifyListeners(); }
  void setMessage(String v) { _message = v; }
  void setType(OfferType t) { _type = t; notifyListeners(); }

  Future<bool> submit() async {
    _state = const Loading(); notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _state = const Success(null);
    notifyListeners();
    return true;
  }
}
