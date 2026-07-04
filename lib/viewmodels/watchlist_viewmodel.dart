import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../models/listing_model.dart';
import '../../repositories/search_repository.dart';

class WatchlistViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();
  final List<Listing> _items = [];
  List<Listing> get items => _items;
  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    final result = await _repository.search();
    if (result is ResultSuccess<List<Listing>>) {
      // Mock: first 3 items as saved
      _items.clear();
      _items.addAll(result.data.take(3));
      notifyListeners();
    }
  }

  void remove(int index) { _items.removeAt(index); notifyListeners(); }
}
