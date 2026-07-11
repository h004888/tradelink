import 'package:flutter/foundation.dart';

/// Service theo dõi analytics events cho TradeLink.
/// Hiện tại dùng debug log, sau này có thể tích hợp Firebase Analytics, Mixpanel, v.v.
///
/// Mỗi event đặt theo chuẩn: `screen_action` (vd: `home_viewed`, `search_submitted`)
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  bool _enabled = true;

  /// Bật/tắt analytics (dùng trong debug)
  void setEnabled(bool enabled) => _enabled = enabled;

  /// Ghi nhận một event
  void track(String eventName, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    // Trong production: gọi FirebaseAnalytics, Mixpanel, v.v.
    // Hiện tại: log debug
    debugPrint('[Analytics] $eventName ${properties ?? ''}');
  }

  // ── Discovery Events ──
  void homeViewed() => track('home_viewed');
  void searchStarted() => track('search_started');
  void searchSubmitted(String query) => track('search_submitted', properties: {'query': query});
  void searchZeroResult(String query) => track('search_zero_result', properties: {'query': query});
  void filterApplied(Map<String, dynamic> filters) => track('filter_applied', properties: filters);
  void listingImpression(String listingId) => track('listing_impression', properties: {'listingId': listingId});
  void listingViewed(String listingId) => track('listing_viewed', properties: {'listingId': listingId});
  void listingSaved(String listingId) => track('listing_saved', properties: {'listingId': listingId});
  void sellerProfileViewed(String sellerId) => track('seller_profile_viewed', properties: {'sellerId': sellerId});

  // ── Intent Events ──
  void buyNowClicked(String listingId) => track('buy_now_clicked', properties: {'listingId': listingId});
  void offerStarted(String listingId) => track('offer_started', properties: {'listingId': listingId});
  void offerSubmitted(String listingId, double amount) => track('offer_submitted', properties: {'listingId': listingId, 'amount': amount});
  void messageSellerClicked(String listingId) => track('message_seller_clicked', properties: {'listingId': listingId});
  void authGateViewed() => track('auth_gate_viewed');
  void authCompletedAfterIntent() => track('auth_completed_after_intent');

  // ── Checkout Events ──
  void checkoutStarted(String listingId) => track('checkout_started', properties: {'listingId': listingId});
  void paymentStarted(String listingId) => track('payment_started', properties: {'listingId': listingId});
  void paymentFailed(String listingId, String reason) => track('payment_failed', properties: {'listingId': listingId, 'reason': reason});
  void paymentHeld(String listingId) => track('payment_held', properties: {'listingId': listingId});

  // ── Transaction Events ──
  void transactionStateChanged(String transactionId, String from, String to) =>
      track('transaction_state_changed', properties: {'transactionId': transactionId, 'from': from, 'to': to});
  void deliveryConfirmed(String transactionId) => track('delivery_confirmed', properties: {'transactionId': transactionId});
  void transactionCompleted(String transactionId) => track('transaction_completed', properties: {'transactionId': transactionId});
  void cancellationRequested(String transactionId) => track('cancellation_requested', properties: {'transactionId': transactionId});

  // ── Dispute Events ──
  void problemReportStarted(String transactionId) => track('problem_report_started', properties: {'transactionId': transactionId});
  void disputeSubmitted(String transactionId) => track('dispute_submitted', properties: {'transactionId': transactionId});
  void disputeResolved(String transactionId, String resolution) =>
      track('dispute_resolved', properties: {'transactionId': transactionId, 'resolution': resolution});

  // ── Review Events ──
  void reviewPromptViewed(String transactionId) => track('review_prompt_viewed', properties: {'transactionId': transactionId});
  void reviewSubmitted(String transactionId) => track('review_submitted', properties: {'transactionId': transactionId});
}
