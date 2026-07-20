class Wallet {
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;

  const Wallet({
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
  });

  factory Wallet.fromJson(Map<String, dynamic> j) {
    return Wallet(
      balance: (j['balance'] as num?)?.toDouble() ?? 0,
      totalEarned: (j['totalEarned'] as num?)?.toDouble() ?? 0,
      totalWithdrawn: (j['totalWithdrawn'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// type: 'credit' | 'debit' — reason: 'sale' | 'withdrawal' | 'withdrawal_refund'
class WalletLedgerEntry {
  final String id;
  final String type;
  final String reason;
  final double amount;
  final double balanceAfter;
  final String? note;
  final DateTime createdAt;

  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.reason,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> j) {
    return WalletLedgerEntry(
      id: j['_id']?.toString() ?? '',
      type: j['type']?.toString() ?? 'credit',
      reason: j['reason']?.toString() ?? '',
      amount: (j['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (j['balanceAfter'] as num?)?.toDouble() ?? 0,
      note: j['note'] as String?,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// status: 'pending' | 'paid' | 'rejected'
class WithdrawalRequestItem {
  final String id;
  final double amount;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountHolder;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime? processedAt;
  // Chỉ có giá trị khi admin gọi API (populate userId) — null với user tự xem ví của mình.
  final String? userName;
  final String? userPhone;

  const WithdrawalRequestItem({
    required this.id,
    required this.amount,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountHolder,
    required this.status,
    this.note,
    required this.createdAt,
    this.processedAt,
    this.userName,
    this.userPhone,
  });

  factory WithdrawalRequestItem.fromJson(Map<String, dynamic> j) {
    final user = j['userId'] is Map ? j['userId'] as Map : null;
    return WithdrawalRequestItem(
      id: j['_id']?.toString() ?? '',
      amount: (j['amount'] as num?)?.toDouble() ?? 0,
      bankName: j['bankName']?.toString() ?? '',
      bankAccountNumber: j['bankAccountNumber']?.toString() ?? '',
      bankAccountHolder: j['bankAccountHolder']?.toString() ?? '',
      status: j['status']?.toString() ?? 'pending',
      note: j['note'] as String?,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      processedAt: j['processedAt'] != null ? DateTime.tryParse(j['processedAt'].toString()) : null,
      userName: user?['fullName'] as String?,
      userPhone: user?['phone'] as String?,
    );
  }
}

class WalletOverview {
  final double totalBalance;
  final double totalPending;
  final double totalPaidOut;

  const WalletOverview({
    required this.totalBalance,
    required this.totalPending,
    required this.totalPaidOut,
  });

  factory WalletOverview.fromJson(Map<String, dynamic> j) {
    return WalletOverview(
      totalBalance: (j['totalBalance'] as num?)?.toDouble() ?? 0,
      totalPending: (j['totalPending'] as num?)?.toDouble() ?? 0,
      totalPaidOut: (j['totalPaidOut'] as num?)?.toDouble() ?? 0,
    );
  }
}
