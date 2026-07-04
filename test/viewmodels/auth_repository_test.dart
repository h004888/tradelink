import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/core/failure.dart';
import 'package:tradelink/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository repo;

    setUp(() => repo = AuthRepository());

    test('login with empty phone returns ValidationFailure', () async {
      final result = await repo.login('');
      expect(result, isA<FailureResult<String>>());
      final failure = (result as FailureResult).failure;
      expect(failure, isA<ValidationFailure>());
    });

    test('login with short phone returns ValidationFailure', () async {
      final result = await repo.login('123');
      expect(result, isA<FailureResult<String>>());
      final failure = (result as FailureResult).failure;
      expect(failure, isA<ValidationFailure>());
    });

    test('login with valid phone returns ResultSuccess', () async {
      final result = await repo.login('0912345678');
      expect(result, isA<ResultSuccess<String>>());
      final data = (result as ResultSuccess).data;
      expect(data, isNotEmpty);
    });

    test('verifyOtp with invalid length returns error', () async {
      final result = await repo.verifyOtp('session', '123');
      expect(result, isA<FailureResult<bool>>());
    });

    test('verifyOtp with wrong code returns AuthFailure', () async {
      final result = await repo.verifyOtp('session', '999999');
      expect(result, isA<FailureResult<bool>>());
      final failure = (result as FailureResult).failure;
      expect(failure, isA<AuthFailure>());
    });

    test('verifyOtp with correct code returns ResultSuccess', () async {
      final result = await repo.verifyOtp('session', '123456');
      expect(result, isA<ResultSuccess<bool>>());
      expect((result as ResultSuccess).data, true);
    });
  });
}
