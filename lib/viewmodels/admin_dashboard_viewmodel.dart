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

  final Set<String> _busyIds = {};
  bool isBusy(String id) => _busyIds.contains(id);
  String? _actionError;
  String? get actionError => _actionError;

  Future<bool> resolveDispute(String disputeId, String resolution, {String? decision}) async {
    _busyIds.add(disputeId);
    _actionError = null;
    notifyListeners();
    final res = await _repository.resolveDispute(disputeId, resolution, decision: decision);
    _busyIds.remove(disputeId);
    if (res is ResultSuccess<Map<String, dynamic>>) {
      await load();
      return true;
    }
    _actionError = (res as FailureResult<Map<String, dynamic>>).failure.message;
    notifyListeners();
    return false;
  }

  Future<bool> moderateListing(String listingId, {required bool approve}) async {
    _busyIds.add(listingId);
    _actionError = null;
    notifyListeners();
    final res = await _repository.moderateListing(listingId, approve: approve);
    _busyIds.remove(listingId);
    if (res is ResultSuccess<bool>) {
      await load();
      return true;
    }
    _actionError = (res as FailureResult<bool>).failure.message;
    notifyListeners();
    return false;
  }
}
