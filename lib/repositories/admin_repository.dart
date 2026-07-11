import '../core/api_client.dart';
import '../core/failure.dart';
import '../core/result.dart';

class Dispute {
  final String id;
  final String transactionId;
  final String reason;
  final String status;
  final bool priority;
  final DateTime createdAt;
  final String? raisedByName;

  const Dispute({
    required this.id,
    required this.transactionId,
    required this.reason,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.raisedByName,
  });

  factory Dispute.fromJson(Map<String, dynamic> j) {
    final raisedBy = j['raisedBy'] is Map ? j['raisedBy'] as Map : null;
    return Dispute(
      id: j['_id']?.toString() ?? '',
      transactionId: j['transactionId']?.toString() ?? '',
      reason: j['reason']?.toString() ?? '',
      status: j['status']?.toString() ?? 'open',
      priority: j['priority'] == true,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      raisedByName: raisedBy?['name'] as String?,
    );
  }
}

class FlaggedListing {
  final String id;
  final String title;
  final String? sellerName;
  final int flags;

  const FlaggedListing({
    required this.id,
    required this.title,
    this.sellerName,
    required this.flags,
  });

  factory FlaggedListing.fromJson(Map<String, dynamic> j) {
    final seller = j['sellerId'] is Map ? j['sellerId'] as Map : null;
    return FlaggedListing(
      id: j['_id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      sellerName: seller?['name'] as String?,
      flags: (j['flags'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminDashboardData {
  final int totalUsers;
  final int totalListings;
  final int activeListings;
  final int totalTransactions;
  final int pendingDisputes;
  final int resolvedToday;
  final double totalRevenue;
  final List<Dispute> recentDisputes;
  final List<FlaggedListing> flaggedListings;

  const AdminDashboardData({
    required this.totalUsers,
    required this.totalListings,
    required this.activeListings,
    required this.totalTransactions,
    required this.pendingDisputes,
    required this.resolvedToday,
    required this.totalRevenue,
    required this.recentDisputes,
    required this.flaggedListings,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> j) {
    return AdminDashboardData(
      totalUsers: (j['totalUsers'] as num?)?.toInt() ?? 0,
      totalListings: (j['totalListings'] as num?)?.toInt() ?? 0,
      activeListings: (j['activeListings'] as num?)?.toInt() ?? 0,
      totalTransactions: (j['totalTransactions'] as num?)?.toInt() ?? 0,
      pendingDisputes: (j['pendingDisputes'] as num?)?.toInt() ?? 0,
      resolvedToday: (j['resolvedToday'] as num?)?.toInt() ?? 0,
      totalRevenue: (j['totalRevenue'] as num?)?.toDouble() ?? 0,
      recentDisputes: ((j['recentDisputes'] as List?) ?? [])
          .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
          .toList(),
      flaggedListings: ((j['flaggedListings'] as List?) ?? [])
          .map((e) => FlaggedListing.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminUserItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final int totalTransactions;
  final double successRate;
  AdminUserItem({required this.id, required this.name, required this.email, required this.role, required this.totalTransactions, required this.successRate});
  factory AdminUserItem.fromJson(Map<String, dynamic> j) => AdminUserItem(
    id: j['_id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    role: j['role']?.toString() ?? 'buyer',
    totalTransactions: (j['totalTransactions'] as num?)?.toInt() ?? 0,
    successRate: (j['successRate'] as num?)?.toDouble() ?? 100,
  );
}

class AdminTransactionItem {
  final String id;
  final String listingTitle;
  final String buyerId;
  final String sellerId;
  final String status;
  final double amount;
  final String type;
  final DateTime createdAt;
  AdminTransactionItem({required this.id, required this.listingTitle, required this.buyerId, required this.sellerId, required this.status, required this.amount, required this.type, required this.createdAt});
  factory AdminTransactionItem.fromJson(Map<String, dynamic> j) => AdminTransactionItem(
    id: j['_id']?.toString() ?? '',
    listingTitle: j['listingTitle']?.toString() ?? '',
    buyerId: j['buyerId']?.toString() ?? '',
    sellerId: j['sellerId']?.toString() ?? '',
    status: j['status']?.toString() ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    type: j['type']?.toString() ?? '',
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class AdminRepository {
  final _api = ApiClient.instance;

  Future<Result<AdminDashboardData>> getDashboard() async {
    final res = await _api.get('/admin/dashboard');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<AdminDashboardData>(AdminDashboardData.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<AdminDashboardData>(f),
    };
  }

  Future<Result<List<AdminUserItem>>> getUsers() async {
    final res = await _api.get('/admin/users');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<AdminUserItem>>(
          ((d['data'] as List?) ?? []).map((e) => AdminUserItem.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<AdminUserItem>>(f),
    };
  }

  Future<Result<List<AdminTransactionItem>>> getTransactions() async {
    final res = await _api.get('/admin/transactions');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<AdminTransactionItem>>(
          ((d['data'] as List?) ?? []).map((e) => AdminTransactionItem.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<AdminTransactionItem>>(f),
    };
  }

  Future<Result<Map<String, dynamic>>> resolveDispute(String disputeId, String resolution) async {
    final res = await _api.patch('/admin/disputes/$disputeId', body: {'resolution': resolution});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(d),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  /// H6 — Admin tạo user (vai trò tuỳ chọn)
  Future<Result<AdminUserItem>> createUser({
    required String email,
    required String name,
    required String password,
    String role = 'buyer',
  }) async {
    final res = await _api.post('/admin/users', body: {
      'email': email,
      'name': name,
      'password': password,
      'role': role,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<AdminUserItem>(AdminUserItem.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<AdminUserItem>(f),
    };
  }

  /// H6 — Admin xóa user
  Future<Result<bool>> deleteUser(String userId) async {
    final res = await _api.delete('/admin/users/$userId');
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// H7 — Admin đổi vai trò
  Future<Result<AdminUserItem>> updateRole(String userId, String role) async {
    final res = await _api.patch('/admin/users/$userId/role', body: {'role': role});
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<AdminUserItem>(AdminUserItem.fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<AdminUserItem>(f),
    };
  }
}
