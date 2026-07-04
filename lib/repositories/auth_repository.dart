import '../../core/failure.dart';
import '../../core/result.dart';

class AuthRepository {
  // Mock — will be replaced with real API calls
  static const String _mockPhone = '0912345678';
  static const String _mockOtp = '123456';

  Future<Result<String>> login(String phone) async {
    await Future.delayed(const Duration(seconds: 1));

    if (phone.isEmpty) {
      return FailureResult(const ValidationFailure(message: 'Vui lòng nhập số điện thoại'));
    }

    if (phone.length < 10) {
      return FailureResult(const ValidationFailure(message: 'Số điện thoại không hợp lệ'));
    }

    // Mock success — return a fake session ID
    return const ResultSuccess('session-mock-12345');
  }

  Future<Result<bool>> verifyOtp(String sessionId, String otp) async {
    await Future.delayed(const Duration(seconds: 1));

    if (otp.length != 6) {
      return FailureResult(const ValidationFailure(message: 'Mã OTP phải có 6 chữ số'));
    }

    if (otp == _mockOtp) {
      return const ResultSuccess(true);
    }

    return FailureResult(const AuthFailure(message: 'Mã OTP không chính xác'));
  }

  Future<void> logout() async {
    // TODO: clear secure storage
  }
}
