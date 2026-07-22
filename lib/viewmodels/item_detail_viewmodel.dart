import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../models/seller_stats.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/watchlist_repository.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();
  final WatchlistRepository _watchlist = WatchlistRepository();
  final String itemId;

  UiState<Listing> _state = const Loading();
  UiState<Listing> get state => _state;

  SellerStats? _sellerStats;
  SellerStats? get sellerStats => _sellerStats;

  bool _isSaved = false;
  bool get isSaved => _isSaved;

  bool _needsAuth = false;
  bool get needsAuth => _needsAuth;

  bool get isListingAvailable {
    final s = _state;
    if (s is! Success<Listing>) return false;
    return s.data.status == ListingStatus.active;
  }

  bool get isCurrentUserSeller {
    final s = _state;
    if (s is! Success<Listing>) return false;
    final currentUserId = ApiClient.instance.getUserId();
    return currentUserId != null && currentUserId == s.data.sellerId;
  }

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
    _sellerStats = null;
    notifyListeners();

    final result = await _repository.getListingById(itemId);
    switch (result) {
      case ResultSuccess(data: final l):
        _state = Success(l);
        // Load seller stats async (không block UI)
        _loadSellerStats(l.sellerId);
      case FailureResult(failure: final f):
        _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> _loadSellerStats(String sellerId) async {
    final result = await _repository.getSellerStats(sellerId);
    if (result is ResultSuccess<SellerStats>) {
      _sellerStats = result.data;
      notifyListeners();
    }
  }

  Future<void> _loadSaved() async {
    if (ApiClient.instance.getToken() == null) return;
    final res = await _watchlist.isSaved(itemId);
    if (res is ResultSuccess<bool>) {
      _isSaved = res.data;
      notifyListeners();
    }
  }

  Future<void> toggleSave() async {
    if (ApiClient.instance.getToken() == null) {
      _needsAuth = true;
      notifyListeners();
      return;
    }
    final s = _state;
    if (s is! Success<Listing>) return;
    final res = await _watchlist.toggleSave(s.data, _isSaved);
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
