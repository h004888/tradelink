import 'package:flutter/foundation.dart';

import '../models/counter_model.dart';

/// ViewModel quản lý state và logic cho HomeView.
///
/// Kế thừa ChangeNotifier để View có thể lắng nghe thay đổi
/// thông qua Provider / context.watch.
class HomeViewModel extends ChangeNotifier {
  // State được giữ trong ViewModel, không phải trong View
  CounterModel _model = const CounterModel();

  int get counter => _model.value;

  void increment() {
    _model = _model.copyWith(value: _model.value + 1);
    notifyListeners(); // Thông báo cho View rebuild
  }
}
