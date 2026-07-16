import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  UiState<AdminDashboardData> _state = const Loading();
  UiState<AdminDashboardData> get state => _state;

  AdminDashboardData get data {
    final s = _state;
    return s is Success<AdminDashboardData> ? s.data : _empty;
  }

  int get pendingDisputes => data.pendingDisputes;
  List<Dispute> get disputes => data.recentDisputes;

  final AdminDashboardData _empty = AdminDashboardData(
    totalUsers: 0,
    totalListings: 0,
    activeListings: 0,
    totalTransactions: 0,
    pendingDisputes: 0,
    resolvedToday: 0,
    totalRevenue: 0,
    recentDisputes: const [],
    flaggedListings: const [],
  );

  AdminDashboardViewModel() { load(); }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getDashboard();
    switch (res) {
      case ResultSuccess<AdminDashboardData>(:final data):
        _state = Success(data);
      case FailureResult<AdminDashboardData>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> resolveDispute(String disputeId, String resolution) async {
    final res = await _repository.resolveDispute(disputeId, resolution);
    if (res is ResultSuccess<Map<String, dynamic>>) {
      // Refresh sau khi resolve thành công
      await load();
    }
  }
}
