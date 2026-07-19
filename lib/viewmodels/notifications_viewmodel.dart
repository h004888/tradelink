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

  /// Đánh dấu 1 thông báo đã đọc — cập nhật local ngay, không cần reload cả danh sách.
  Future<void> markRead(String id) async {
    final s = _state;
    if (s is! Success<List<AppNotification>>) return;
    final idx = s.data.indexWhere((n) => n.id == id);
    if (idx == -1 || s.data[idx].isRead) return;

    final res = await _repo.markRead(id);
    if (res is ResultSuccess<bool>) {
      _state = Success([
        for (final n in s.data) n.id == id ? n.copyWith(isRead: true) : n,
      ]);
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final s = _state;
    if (s is! Success<List<AppNotification>>) return;
    final res = await _repo.markAllRead();
    if (res is ResultSuccess<bool>) {
      _state = Success([for (final n in s.data) n.copyWith(isRead: true)]);
      notifyListeners();
    }
  }
}
