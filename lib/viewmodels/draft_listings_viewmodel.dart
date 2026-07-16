import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/listing_model.dart';

class DraftListingsViewModel extends ChangeNotifier {

  List<Listing> _drafts = [];
  List<Listing> get drafts => _drafts;
  bool get isEmpty => _drafts.isEmpty;

  DraftListingsViewModel() { load(); }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final draftList = prefs.getStringList('draft_listings') ?? [];
    
    _drafts = draftList.map((str) {
      final j = jsonDecode(str) as Map<String, dynamic>;
      return Listing(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble(),
        exchangeFor: j['exchangeFor'] as String?,
        imageUrls: (j['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        category: j['category'] as String? ?? '',
        condition: ItemCondition.values.firstWhere(
          (e) => e.name == j['condition'],
          orElse: () => ItemCondition.used,
        ),
        type: ListingType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => ListingType.sale,
        ),
        status: ListingStatus.draft,
        sellerId: 'local',
        sellerName: 'Draft',
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
        views: 0,
        interests: 0,
        saves: 0,
      );
    }).toList();
    
    notifyListeners();
  }

  Future<void> deleteDraft(int index) async {
    _drafts.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    final draftList = prefs.getStringList('draft_listings') ?? [];
    if (index >= 0 && index < draftList.length) {
      draftList.removeAt(index);
      await prefs.setStringList('draft_listings', draftList);
    }
    notifyListeners();
  }
}
