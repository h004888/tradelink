import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../repositories/listing_repository.dart';

class DraftListingsViewModel extends ChangeNotifier {
  final ListingRepository _repository = ListingRepository();

  List<Listing> _drafts = [];
  List<Listing> get drafts => _drafts;

  DraftListingsViewModel() { load(); }

  void load() { _drafts = _repository.getDrafts(); notifyListeners(); }

  void deleteDraft(int index) { _drafts.removeAt(index); notifyListeners(); }

  bool get isEmpty => _drafts.isEmpty;
}
