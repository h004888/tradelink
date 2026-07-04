import 'package:flutter/material.dart';
import '../../core/ui_state.dart';

class DisputeViewModel extends ChangeNotifier {
  final String transactionId;

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;
  String _reason = '';
  String get reason => _reason;
  String _description = '';
  String get description => _description;

  DisputeViewModel({required this.transactionId});

  void setReason(String v) { _reason = v; }
  void setDescription(String v) { _description = v; }

  Future<bool> submit() async {
    _state = const Loading(); notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _state = const Success(null); notifyListeners();
    return true;
  }
}
