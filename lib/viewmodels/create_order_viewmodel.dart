import 'package:flutter/material.dart';
import '../../core/ui_state.dart';

class CreateOrderViewModel extends ChangeNotifier {
  final String listingId;
  UiState<void> _state = const Idle();
  UiState<void> get state => _state;
  bool _agreed = false;
  bool get agreed => _agreed;

  CreateOrderViewModel({required this.listingId});

  void toggleAgree(bool? v) { _agreed = v ?? false; notifyListeners(); }

  Future<bool> confirm() async {
    _state = const Loading(); notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _state = const Success(null); notifyListeners();
    return true;
  }
}
