class Profile {
  final String id;
  final String fullName;
  final String phone;
  final String? avatar;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int uyTinScore;
  final int successfulTransactions;
  final double successRate;
  final int totalListings;
  final List<String>? badges;
  final DateTime memberSince;

  const Profile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.avatar,
    this.address,
    this.latitude,
    this.longitude,
    this.uyTinScore = 0,
    this.successfulTransactions = 0,
    this.successRate = 100,
    this.totalListings = 0,
    this.badges,
    required this.memberSince,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      uyTinScore: (json['uyTinScore'] as num?)?.toInt() ??
          (json['reputationScore'] as num?)?.toInt() ??
          0,
      successfulTransactions:
          (json['successfulTransactions'] as num?)?.toInt() ??
              (json['totalTransactions'] as num?)?.toInt() ??
              0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 100,
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List?)?.map((e) => e.toString()).toList(),
      memberSince: DateTime.tryParse(json['memberSince']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'uyTinScore': uyTinScore,
      'successfulTransactions': successfulTransactions,
      'successRate': successRate,
      'totalListings': totalListings,
      'badges': badges,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? phone,
    String? avatar,
    String? address,
    double? latitude,
    double? longitude,
    int? uyTinScore,
    int? successfulTransactions,
    double? successRate,
    int? totalListings,
    List<String>? badges,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      uyTinScore: uyTinScore ?? this.uyTinScore,
      successfulTransactions:
          successfulTransactions ?? this.successfulTransactions,
      successRate: successRate ?? this.successRate,
      totalListings: totalListings ?? this.totalListings,
      badges: badges ?? this.badges,
      memberSince: memberSince,
    );
  }

  String get reputationTier {
    if (uyTinScore >= 90) return 'Vàng';
    if (uyTinScore >= 70) return 'Bạc';
    if (uyTinScore >= 50) return 'Đồng';
    return 'Mới';
  }
}
