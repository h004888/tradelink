import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/watchlist_repository.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final WatchlistRepository _watchlist = WatchlistRepository();
  final String itemId;

  UiState<Listing> _state = const Loading();
  UiState<Listing> get state => _state;
  bool _isSaved = false;
  bool get isSaved => _isSaved;
  bool _needsAuth = false;
  bool get needsAuth => _needsAuth;

  /// Listing có available để mua/offer không
  bool get isListingAvailable {
    final s = _state;
    if (s is! Success<Listing>) return false;
    return s.data.status == ListingStatus.active;
  }

  /// Người dùng hiện tại có phải là seller của listing này không
  bool get isCurrentUserSeller {
    final s = _state;
    if (s is! Success<Listing>) return false;
    final currentUserId = ApiClient.instance.getUserId();
    return currentUserId != null && currentUserId == s.data.sellerId;
  }

  /// Lý do listing không available (nếu có)
  String? get unavailableReason {
    final s = _state;
    if (s is! Success<Listing>) return null;
    if (s.data.status == ListingStatus.active) return null;
    return switch (s.data.status) {
      ListingStatus.sold => 'Sản phẩm đã được bán',
      ListingStatus.hidden => 'Sản phẩm hiện không được bán',
      ListingStatus.draft => 'Sản phẩm chưa được đăng bán',
      _ => null,
    };
  }

  ItemDetailViewModel({required this.itemId}) {
    load();
    _loadSaved();
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final result = await _repository.getListingById(itemId);
    switch (result) {
      case ResultSuccess(data: final l):
        _state = Success(l);
      case FailureResult(failure: final f):
        _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> _loadSaved() async {
    // Guest không check saved status
    if (ApiClient.instance.getToken() == null) return;
    final res = await _watchlist.isSaved(itemId);
    if (res is ResultSuccess<bool>) {
      _isSaved = res.data;
      notifyListeners();
    }
  }

  Future<void> toggleSave() async {
    // Auth Gate: guest → báo cần đăng nhập
    if (ApiClient.instance.getToken() == null) {
      _needsAuth = true;
      notifyListeners();
      return;
    }
    final res = await _watchlist.toggleSave(itemId, _isSaved);
    if (res is ResultSuccess<bool>) {
      _isSaved = res.data;
      notifyListeners();
    }
  }

  void clearNeedsAuth() {
    _needsAuth = false;
    notifyListeners();
  }
}
