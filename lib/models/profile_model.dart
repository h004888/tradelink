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
  final DateTime memberSince;

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
    required this.memberSince,
  });

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
      memberSince: memberSince,
    );
  }

  String get reputationTier {
    if (reputationScore >= 90) return 'Vàng';
    if (reputationScore >= 70) return 'Bạc';
    if (reputationScore >= 50) return 'Đồng';
    return 'Mới';
  }
}
