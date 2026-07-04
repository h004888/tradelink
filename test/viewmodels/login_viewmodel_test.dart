import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/viewmodels/login_viewmodel.dart';

void main() {
  group('LoginViewModel', () {
    test('initial state is Idle', () {
      final vm = LoginViewModel();
      expect(vm.state, isA<Idle>());
      expect(vm.phone, isEmpty);
    });

    test('onPhoneChanged updates phone', () {
      final vm = LoginViewModel();
      vm.onPhoneChanged('0912345678');
      expect(vm.phone, '0912345678');
    });

    test('login transitions to Loading then Success/Error', () async {
      final vm = LoginViewModel();
      vm.onPhoneChanged('0912345678');

      final future = vm.login();
      // Should be Loading while request is in flight
      expect(vm.state, isA<Loading>());

      await future;
      // After completion should be Success or Error
      expect(vm.state, anyOf(isA<Success<String>>(), isA<Error<String>>()));
    });

    test('empty phone transitions to Error', () async {
      final vm = LoginViewModel();
      await vm.login();
      expect(vm.state, isA<Error<String>>());
    });
  });
}
