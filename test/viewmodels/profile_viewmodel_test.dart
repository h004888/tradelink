import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/viewmodels/profile_viewmodel.dart';

void main() {
  group('ProfileViewModel', () {
    test('initial state is Loading', () {
      final vm = ProfileViewModel();
      expect(vm.state, isA<Loading<dynamic>>());
    });

    test('loadProfile transitions to Success with mock data', () async {
      final vm = ProfileViewModel();
      // Wait for async load
      await Future.delayed(const Duration(milliseconds: 600));
      expect(vm.state, isA<Success<dynamic>>());
      expect(vm.profile, isNotNull);
      expect(vm.profile!.name, 'Nguyễn Minh Khôi');
      expect(vm.profile!.reputationScore, 85);
      expect(vm.profile!.reputationTier, 'Bạc');
    });

    test('reputation tier is correct', () async {
      final vm = ProfileViewModel();
      await Future.delayed(const Duration(milliseconds: 600));
      final profile = vm.profile!;
      expect(profile.reputationTier, 'Bạc'); // 85 → Bạc
      expect(profile.totalTransactions, 42);
      expect(profile.successRate, 97.6);
    });
  });
}
