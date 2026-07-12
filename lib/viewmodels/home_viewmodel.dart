import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/filter_model.dart';
import '../../models/listing_model.dart';
import '../../models/transaction_model.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/analytics_service.dart';
import '../../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final ListingRepository _listingRepo = ListingRepository();
  final TransactionRepository _txRepo = TransactionRepository();

  // ── Feed state ──
  UiState<List<Listing>> _feedState = const Loading();
  UiState<List<Listing>> get feedState => _feedState;

  // ── Filter state ──
  FeedFilter _filter = const FeedFilter();
  FeedFilter get filter => _filter;

  // ── Active transactions ──
  UiState<List<Transaction>> _activeTransactions = const Loading();
  UiState<List<Transaction>> get activeTransactions => _activeTransactions;

  bool get hasActiveTransaction => switch (_activeTransactions) {
    Success(data: final txs) => txs.any((t) => t.escrowStep != null && t.escrowStep != EscrowStep.released),
    _ => false,
  };

  // ── Pagination state ──
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _loadMoreError;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;

  static const int _maxPage = 50;

  HomeViewModel() { load(); }

  Future<void> load() async {
    AnalyticsService.instance.track('home_viewed');

    _page = 1;
    _hasMore = true;
    _loadMoreError = null;
    _feedState = const Loading();
    _activeTransactions = const Loading();
    notifyListeners();

    final futures = <Future>[
      _listingRepo.getFeed(page: 1, filter: _filter).then((r) {
        _feedState = r is ResultSuccess<FeedData>
            ? Success(r.data.listings)
            : Error(message: (r as FailureResult<FeedData>).failure.message, retryable: true);
        if (r is ResultSuccess<FeedData>) {
          _hasMore = r.data.hasMore;
        }
      }),
    ];

    if (ApiClient.instance.getToken() != null) {
      futures.add(_txRepo.getAll().then((r) {
        _activeTransactions = r is ResultSuccess<List<Transaction>>
            ? Success(r.data)
            : Error(message: (r as FailureResult<List<Transaction>>).failure.message, retryable: true);
      }));
    } else {
      _activeTransactions = const Error(message: 'Vui lòng đăng nhập để xem giao dịch');
    }

    await Future.wait(futures);
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _page >= _maxPage) return;

    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    _page++;
    final res = await _listingRepo.getFeed(page: _page, filter: _filter);

    if (res is ResultSuccess<FeedData>) {
      final currentListings = (_feedState as Success<List<Listing>>).data;
      _feedState = Success([...currentListings, ...res.data.listings]);
      _hasMore = res.data.hasMore;

      AnalyticsService.instance.track('home_load_more', properties: {
        'page': _page,
        'items_loaded': res.data.listings.length,
      });
    } else {
      _loadMoreError = (res as FailureResult<FeedData>).failure.message;
      _page--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> retryLoadMore() async {
    if (_loadMoreError != null) {
      await loadMore();
    }
  }

  void updateFilter(FeedFilter newFilter) {
    _filter = newFilter;
    load();
  }

  void resetFilter() {
    _filter = const FeedFilter();
    load();
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
