import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  UiState<List<AppNotification>> _state = const Loading();
  UiState<List<AppNotification>> get state => _state;

  NotificationsViewModel() { load(); }

  Future<void> load() async {
    _state = const Loading(); notifyListeners();
    final r = await _repo.getAll();
    switch (r) { case ResultSuccess(data: final list): _state = Success(list); case FailureResult(failure: final f): _state = Error(message: f.message); }
    notifyListeners();
  }
}
