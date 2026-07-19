import '../core/api_client.dart';
import '../core/result.dart';

class Dispute {
  final String id;
  final String transactionId;
  final String reason;
  final String description;
  final String status;
  final bool priority;
  final String? resolution;
  final String? decision;
  final List<String> attachments;
  final String? chatLogSnapshot;
  final DateTime createdAt;
  final String? raisedByName;

  const Dispute({
    required this.id,
    required this.transactionId,
    required this.reason,
    required this.description,
    required this.status,
    required this.priority,
    this.resolution,
    this.decision,
    this.attachments = const [],
    this.chatLogSnapshot,
    required this.createdAt,
    this.raisedByName,
  });

  factory Dispute.fromJson(Map<String, dynamic> j) {
    final raisedBy = j['raisedBy'] is Map ? j['raisedBy'] as Map : null;
    return Dispute(
      id: j['_id']?.toString() ?? '',
      transactionId: (j['transactionId'] is Map ? j['transactionId']['_id'] : j['transactionId'])?.toString() ?? '',
      reason: j['reason']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      status: j['status']?.toString() ?? 'open',
      priority: j['priority'] == true,
      resolution: j['resolution'] as String?,
      decision: j['decision'] as String?,
      attachments: ((j['attachments'] as List?) ?? []).map((e) => e.toString()).toList(),
      chatLogSnapshot: j['chatLogSnapshot'] as String?,
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
    role: j['role']?.toString() ?? 'user',
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
    buyerId: (j['buyerId'] is Map ? j['buyerId']['_id'] : j['buyerId'])?.toString() ?? '',
    sellerId: (j['sellerId'] is Map ? j['sellerId']['_id'] : j['sellerId'])?.toString() ?? '',
    status: j['escrowStep']?.toString() ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    type: j['type']?.toString() ?? '',
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class PendingPayoutItem {
  final String id;
  final String listingTitle;
  final double amount;
  final String sellerName;
  final String? sellerPhone;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final DateTime updatedAt;

  const PendingPayoutItem({
    required this.id,
    required this.listingTitle,
    required this.amount,
    required this.sellerName,
    this.sellerPhone,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    required this.updatedAt,
  });

  factory PendingPayoutItem.fromJson(Map<String, dynamic> j) {
    final seller = j['sellerId'] is Map ? j['sellerId'] as Map : const {};
    return PendingPayoutItem(
      id: j['_id']?.toString() ?? '',
      listingTitle: j['listingTitle']?.toString() ?? '',
      amount: (j['amount'] as num?)?.toDouble() ?? 0,
      sellerName: seller['name']?.toString() ?? 'Không rõ',
      sellerPhone: seller['phone'] as String?,
      bankName: seller['bankName'] as String?,
      bankAccountNumber: seller['bankAccountNumber'] as String?,
      bankAccountHolder: seller['bankAccountHolder'] as String?,
      updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
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

  Future<Result<List<PendingPayoutItem>>> getPendingPayouts() async {
    final res = await _api.get('/admin/payouts');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<PendingPayoutItem>>(
          ((d['data'] as List?) ?? []).map((e) => PendingPayoutItem.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<PendingPayoutItem>>(f),
    };
  }

  Future<Result<bool>> markPayoutPaid(String transactionId) async {
    final res = await _api.patch('/admin/payouts/$transactionId/mark-paid');
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  Future<Result<Map<String, dynamic>>> resolveDispute(String disputeId, String resolution, {String? decision}) async {
    final res = await _api.patch('/admin/disputes/$disputeId', body: {
      'resolution': resolution,
      'decision': ?decision,
    });
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Map<String, dynamic>>(d),
      FailureResult(failure: final f) => FailureResult<Map<String, dynamic>>(f),
    };
  }

  /// Duyệt/gỡ 1 tin bị báo cáo.
  Future<Result<bool>> moderateListing(String listingId, {required bool approve}) async {
    final res = await _api.patch('/admin/listings/$listingId/moderate', body: {
      'action': approve ? 'approve' : 'reject',
    });
    return switch (res) {
      ResultSuccess() => ResultSuccess<bool>(true),
      FailureResult(failure: final f) => FailureResult<bool>(f),
    };
  }

  /// H6 — Admin tạo user (vai trò tuỳ chọn)
  Future<Result<AdminUserItem>> createUser({
    required String email,
    required String name,
    required String password,
    String role = 'user',
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
