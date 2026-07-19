class Profile {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int reputationScore;
  final int totalTransactions;
  final double successRate;
  final int totalListings;
  final String role;
  final DateTime memberSince;
  // Thông tin nhận tiền — admin dùng để chuyển khoản thủ công khi bán hàng thành công.
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;

  const Profile({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.reputationScore = 0,
    this.totalTransactions = 0,
    this.successRate = 100,
    this.totalListings = 0,
    this.role = 'user',
    required this.memberSince,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
  });

  bool get isAdmin => role == 'admin';

  Profile copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    double? latitude,
    double? longitude,
    int? reputationScore,
    int? totalTransactions,
    double? successRate,
    int? totalListings,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reputationScore: reputationScore ?? this.reputationScore,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      successRate: successRate ?? this.successRate,
      totalListings: totalListings ?? this.totalListings,
      role: role,
      memberSince: memberSince,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
    );
  }

  String get reputationTier {
    if (reputationScore >= 90) return 'Vàng';
    if (reputationScore >= 70) return 'Bạc';
    if (reputationScore >= 50) return 'Đồng';
    return 'Mới';
  }
}
