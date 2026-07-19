import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class TransactionTradeViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final String transactionId;

  UiState<Transaction> _state = const Loading();
  UiState<Transaction> get state => _state;

  String? _currentUserId;

  bool _confirming = false;
  bool get isConfirming => _confirming;
  String? _actionError;
  String? get actionError => _actionError;

  TransactionTradeViewModel({required this.transactionId}) { load(); }

  // D5 — view trade
  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final meR = await ApiClient.instance.get('/auth/me');
    if (meR is ResultSuccess<Map<String, dynamic>>) {
      _currentUserId = ((meR.data['data'] as Map)['_id'] ?? '').toString();
    }
    final r = await _repo.getById(transactionId);
    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
    } else if (r is FailureResult<Transaction>) {
      _state = Error(message: r.failure.message, retryable: true);
    }
    notifyListeners();
  }

  /// Backend coi buyer = party A, seller = party B.
  /// Trả về null nếu user hiện tại không phải buyer/seller của giao dịch này.
  String? get myParty {
    final s = _state;
    if (s is! Success<Transaction> || _currentUserId == null) return null;
    if (_currentUserId == s.data.buyerId) return 'A';
    if (_currentUserId == s.data.sellerId) return 'B';
    return null;
  }

  /// userId của người được đánh giá (bên kia của giao dịch) — dùng cho nút "Đánh giá đối tác".
  String? targetId() {
    final s = _state;
    if (s is! Success<Transaction> || _currentUserId == null) return null;
    final tx = s.data;
    return _currentUserId == tx.buyerId ? tx.sellerId : tx.buyerId;
  }

  // D6 — confirm trade (party sent/received)
  Future<bool> confirmTrade(String party, bool sent, bool received) async {
    _confirming = true;
    _actionError = null;
    notifyListeners();

    final r = await _repo.confirmTrade(transactionId, party, sent, received);
    _confirming = false;

    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
      notifyListeners();
      return true;
    }
    if (r is FailureResult<Transaction>) {
      _actionError = r.failure.message;
    } else {
      _actionError = 'Lỗi không xác định';
    }
    notifyListeners();
    return false;
  }

  /// Đánh dấu "đã gửi đồ" cho bên hiện tại — giữ nguyên cờ "đã nhận" đang có.
  Future<bool> markMySent(bool value) {
    final s = _state;
    final party = myParty;
    if (s is! Success<Transaction> || party == null) return Future.value(false);
    final tx = s.data;
    final currentReceived = party == 'A' ? (tx.partyAReceived ?? false) : (tx.partyBReceived ?? false);
    return confirmTrade(party, value, currentReceived);
  }

  /// Đánh dấu "đã nhận đồ" cho bên hiện tại — giữ nguyên cờ "đã gửi" đang có.
  Future<bool> markMyReceived(bool value) {
    final s = _state;
    final party = myParty;
    if (s is! Success<Transaction> || party == null) return Future.value(false);
    final tx = s.data;
    final currentSent = party == 'A' ? (tx.partyASent ?? false) : (tx.partyBSent ?? false);
    return confirmTrade(party, currentSent, value);
  }
}
