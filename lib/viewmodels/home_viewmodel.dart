import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/analytics_service.dart';
import '../../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final ListingRepository _listingRepo = ListingRepository();
  final TransactionRepository _txRepo = TransactionRepository();

  // ── Unified home data ──
  UiState<HomeData> _homeData = const Loading();
  UiState<HomeData> get homeData => _homeData;

  // ── Active transactions ──
  UiState<List<Transaction>> _activeTransactions = const Loading();
  UiState<List<Transaction>> get activeTransactions => _activeTransactions;

  /// Có ít nhất 1 giao dịch chưa hoàn tất
  bool get hasActiveTransaction => switch (_activeTransactions) {
    Success(data: final txs) => txs.any((t) => t.escrowStep != null && t.escrowStep != EscrowStep.released),
    _ => false,
  };

  // ── Categories filter ──
  static const List<String> categories = [
    'Tất cả', 'Điện thoại', 'Laptop', 'Xe cộ',
    'Thời trang', 'Điện tử', 'Phụ kiện', 'Đồ gia dụng', 'Khác',
  ];
  int _selectedCategory = 0;
  int get selectedCategory => _selectedCategory;
  String get selectedCategoryName => categories[_selectedCategory];

  HomeViewModel() { load(); }

  Future<void> load() async {
    AnalyticsService.instance.track('home_viewed');

    _homeData = const Loading();
    _activeTransactions = const Loading();
    notifyListeners();

    // Song song: home data + transactions (nếu có token)
    final futures = <Future>[
      _listingRepo.getHomeData().then((r) {
        _homeData = r is ResultSuccess<HomeData>
            ? Success(r.data)
            : Error(message: (r as FailureResult<HomeData>).failure.message, retryable: true);
      }),
    ];

    if (ApiClient.instance.getToken() != null) {
      futures.add(_txRepo.getAll().then((r) {
        _activeTransactions = r is ResultSuccess<List<Transaction>>
            ? Success(r.data)
            : const Success([]); // fallback: empty → card ẩn
      }));
    } else {
      _activeTransactions = const Success([]);
    }

    await Future.wait(futures);
    notifyListeners();
  }

  Future<void> selectCategory(int i) async {
    _selectedCategory = i;
    notifyListeners();
  }

  void goToSearch(BuildContext context) => context.push(AppPaths.search);
  void goToCategory(BuildContext context, String name) =>
      context.push('${AppPaths.category}/${Uri.encodeComponent(name)}');
  void goToItemDetail(BuildContext context, String id) =>
      context.push('${AppPaths.itemDetail}/$id');
  void goToTransactionDetail(BuildContext context, Transaction tx) {
    final path = tx.type == TransactionType.trade
        ? '${AppPaths.transactionTrade}/${tx.id}'
        : '${AppPaths.transactionSale}/${tx.id}';
    context.push(path);
  }
}
