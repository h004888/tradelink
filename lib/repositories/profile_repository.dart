import '../../core/result.dart';
import '../../models/profile_model.dart';

class ProfileRepository {
  // Mock data
  final Profile _mockProfile = Profile(
    id: 'user-001',
    name: 'Nguyễn Minh Khôi',
    phone: '0912345678',
    address: 'Quận 1, TP. Hồ Chí Minh',
    reputationScore: 85,
    totalTransactions: 42,
    successRate: 97.6,
    totalListings: 15,
    memberSince: DateTime(2025, 1, 15),
  );

  Future<Result<Profile>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ResultSuccess(_mockProfile);
  }

  Future<Result<Profile>> updateProfile(Profile updated) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ResultSuccess(updated);
  }
}
