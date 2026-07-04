import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/models/listing_model.dart';
import 'package:tradelink/viewmodels/create_listing_viewmodel.dart';

void main() {
  group('CreateListingViewModel', () {
    test('initial state is Idle', () {
      final vm = CreateListingViewModel();
      expect(vm.state, isA<Idle>());
      expect(vm.type, ListingType.sale);
      // category defaults to 'Điện tử' which counts as 1 filled field = 20%
      expect(vm.completionPercent, 20);
    });

    test('setType changes type', () {
      final vm = CreateListingViewModel();
      vm.setType(ListingType.trade);
      expect(vm.type, ListingType.trade);
    });

    test('completionPercent increases as fields are filled', () {
      final vm = CreateListingViewModel();
      expect(vm.completionPercent, 20); // category already set

      vm.setTitle('Test Item');
      expect(vm.completionPercent, greaterThan(20));

      vm.setDescription('A description');
      vm.addImage('img.jpg');
      vm.setPrice('100000');

      // title + description + image + price + category = 5/5 = 100%
      // (type=sale means price check auto-passes since price != null)
      expect(vm.completionPercent, 100);
    });

    test('setPrice parses numbers correctly', () {
      final vm = CreateListingViewModel();
      vm.setPrice('45000000');
      expect(vm.price, 45000000);

      vm.setPrice('invalid');
      expect(vm.price, isNull);
    });

    test('publish transitions to Loading then Success', () async {
      final vm = CreateListingViewModel();
      vm.setTitle('Test');
      vm.setDescription('Desc');
      vm.addImage('img.jpg');
      vm.setPrice('100000');

      final future = vm.publish();
      expect(vm.state, isA<Loading>());
      await future;
      expect(vm.state, isA<Success<Listing>>());
    });

    test('categories list is not empty', () {
      expect(CreateListingViewModel.categories, isNotEmpty);
      expect(CreateListingViewModel.categories, contains('Điện tử'));
    });
  });
}
