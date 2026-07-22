import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../models/listing_model.dart';
import '../../repositories/watchlist_repository.dart';

class WatchlistViewModel extends ChangeNotifier {
  final WatchlistRepository _repository = WatchlistRepository();

  final List<Listing> _items = [];
  List<Listing> get items => _items;
  bool get isEmpty => _items.isEmpty;
  bool _loading = false;
  bool get isLoading => _loading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    final result = await _repository.getAll();
    if (result is ResultSuccess<List<Listing>>) {
      _items
        ..clear()
        ..addAll(result.data);
    } else if (result is FailureResult<List<Listing>>) {
      _errorMessage = (result).failure.message;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> remove(String listingId) async {
    final res = await _repository.unsave(listingId);
    if (res is ResultSuccess<bool>) {
      _items.removeWhere((l) => l.id == listingId);
      notifyListeners();
    }
  }
}
