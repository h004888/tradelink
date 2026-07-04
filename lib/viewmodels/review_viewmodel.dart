import 'package:flutter/material.dart';
import '../../core/ui_state.dart';

class ReviewViewModel extends ChangeNotifier {
  final String transactionId;

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;
  int _rating = 0;
  int get rating => _rating;
  int _communication = 0, _punctuality = 0, _quality = 0;
  int get communication => _communication;
  int get punctuality => _punctuality;
  int get quality => _quality;
  String _comment = '';
  String get comment => _comment;

  ReviewViewModel({required this.transactionId});

  void setRating(int v) { _rating = v; notifyListeners(); }
  void setCommunication(int v) { _communication = v; notifyListeners(); }
  void setPunctuality(int v) { _punctuality = v; notifyListeners(); }
  void setQuality(int v) { _quality = v; notifyListeners(); }
  void setComment(String v) { _comment = v; }

  Future<bool> submit() async {
    _state = const Loading(); notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _state = const Success(null); notifyListeners();
    return true;
  }
}
