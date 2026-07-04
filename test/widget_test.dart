import 'package:flutter_test/flutter_test.dart';

import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/core/failure.dart';

void main() {
  group('Core Types', () {
    test('UiState sealed classes', () {
      expect(const Idle<void>(), isA<UiState<void>>());
      expect(const Loading<void>(), isA<UiState<void>>());
      expect(const Success<int>(42), isA<UiState<int>>());
      expect((const Success<int>(42)).data, 42);
      expect(const Error<void>(message: 'err'), isA<UiState<void>>());
      expect((const Error<void>(message: 'err', retryable: true)).retryable, true);
    });

    test('Result sealed classes', () {
      expect(const ResultSuccess<String>('ok'), isA<Result<String>>());
      expect((const ResultSuccess<String>('ok')).data, 'ok');
      expect(FailureResult<String>(const UnknownFailure(message: 'err')), isA<Result<String>>());
      expect((FailureResult<String>(const UnknownFailure(message: 'err')).failure).message, 'err');
    });

    test('Failure types', () {
      final nf = NetworkFailure(message: 'No connection', statusCode: 500);
      expect(nf.message, 'No connection');
      expect(nf.statusCode, 500);

      final af = AuthFailure(message: 'Unauthorized');
      expect(af.message, 'Unauthorized');

      final vf = ValidationFailure(message: 'Invalid', fieldErrors: {'email': 'Required'});
      expect(vf.fieldErrors?['email'], 'Required');
    });
  });
}
