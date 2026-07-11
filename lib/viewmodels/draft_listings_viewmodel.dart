import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class DraftListingsViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();

  List<Listing> _drafts = [];
  List<Listing> get drafts => _drafts;
  bool get isEmpty => _drafts.isEmpty;

  DraftListingsViewModel() { load(); }

  Future<void> load() async {
    final result = await _repository.getDrafts();
    if (result is ResultSuccess<List<Listing>>) {
      _drafts = result.data;
    }
    notifyListeners();
  }

  void deleteDraft(int index) {
    _drafts.removeAt(index);
    notifyListeners();
  }
}
