import 'package:flutter/material.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  int _pendingDisputes = 5;
  int get pendingDisputes => _pendingDisputes;
  int _resolvedToday = 3;
  int get resolvedToday => _resolvedToday;
  int _pendingReviews = 12;
  int get pendingReviews => _pendingReviews;

  // Mock disputes
  final List<_DisputeItem> disputes = const [
    _DisputeItem(id: 'TC-042', type: 'BÁN', complainant: 'Minh Hoàng', respondent: 'Thu Trang', reason: 'Hàng sai mô tả', time: '2 giờ trước', priority: true),
    _DisputeItem(id: 'TC-043', type: 'TRAO ĐỔI', complainant: 'Anh Quân', respondent: 'Hương Ly', reason: 'Không gửi đồ', time: '5 giờ trước', priority: false),
  ];

  // Mock pending listings
  final List<_PendingListing> pendingListings = const [
    _PendingListing(title: 'iPhone 15 Pro Max', seller: 'Trọng Nghĩa', flags: 4),
  ];
}

class _DisputeItem { final String id, type, complainant, respondent, reason, time; final bool priority; const _DisputeItem({required this.id, required this.type, required this.complainant, required this.respondent, required this.reason, required this.time, required this.priority}); }
class _PendingListing { final String title, seller; final int flags; const _PendingListing({required this.title, required this.seller, required this.flags}); }
