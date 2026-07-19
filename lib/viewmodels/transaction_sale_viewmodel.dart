import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class TransactionSaleViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final String transactionId;

  UiState<Transaction> _state = const Loading();
  UiState<Transaction> get state => _state;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  bool _advancing = false;
  bool get isAdvancing => _advancing;
  String? _actionError;
  String? get actionError => _actionError;

  UiState<PaymentInfo> _paymentInfo = const Idle();
  UiState<PaymentInfo> get paymentInfo => _paymentInfo;
  Timer? _pollTimer;

  /// Nhãn nút hành động theo từng bước escrow — null nếu bước hiện tại
  /// không cần thao tác thủ công. 'paymentPending' không có trong map này —
  /// bước đó giờ được xác nhận tự động qua webhook SePay (xem _loadPaymentInfoIfNeeded),
  /// không còn cho người mua tự bấm xác nhận.
  static const Map<EscrowStep, String> _actionLabels = {
    EscrowStep.paymentConfirmed: 'Xác nhận đã gửi hàng',
    EscrowStep.shipping: 'Xác nhận đã nhận hàng',
    EscrowStep.delivered: 'Hoàn tất, giải ngân cho người bán',
  };

  /// true = buyer thao tác bước này, false = seller thao tác bước này.
  static const Map<EscrowStep, bool> _actorIsBuyer = {
    EscrowStep.paymentConfirmed: false,
    EscrowStep.shipping: true,
    EscrowStep.delivered: true,
  };

  TransactionSaleViewModel({required this.transactionId}) { load(); }

  // D2/D3 — view buyer/seller
  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final meR = await ApiClient.instance.get('/auth/me');
    if (meR is ResultSuccess<Map<String, dynamic>>) {
      _currentUserId = ((meR.data['data'] as Map)['_id'] ?? '').toString();
    }
    await _refreshTransaction();
  }

  Future<void> _refreshTransaction() async {
    final r = await _repo.getById(transactionId);
    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
      _syncPaymentPolling(r.data);
    } else if (r is FailureResult<Transaction>) {
      _state = Error(message: r.failure.message, retryable: true);
    }
    notifyListeners();
  }

  /// Bước 'paymentPending' → tải thông tin QR (1 lần) + bật polling để tự phát hiện
  /// khi webhook SePay xác nhận thanh toán (không cần người dùng tự bấm/tải lại).
  void _syncPaymentPolling(Transaction tx) {
    if (tx.escrowStep != EscrowStep.paymentPending) {
      _pollTimer?.cancel();
      _pollTimer = null;
      _paymentInfo = const Idle();
      return;
    }

    if (_paymentInfo is Idle) {
      _loadPaymentInfo();
    }
    _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) => _refreshTransaction());
  }

  Future<void> _loadPaymentInfo() async {
    _paymentInfo = const Loading();
    notifyListeners();
    final r = await _repo.getPaymentInfo(transactionId);
    _paymentInfo = switch (r) {
      ResultSuccess(data: final info) => Success(info),
      FailureResult(failure: final f) => Error(message: f.message),
    };
    notifyListeners();
  }

  /// Trả về userId của người được đánh giá (bên kia của transaction).
  String? targetId() {
    final s = _state;
    if (s is! Success<Transaction>) return null;
    if (_currentUserId == null) return null;
    final tx = s.data;
    return _currentUserId == tx.buyerId ? tx.sellerId : tx.buyerId;
  }

  bool isBuyer() {
    final s = _state;
    if (s is! Success<Transaction>) return false;
    return _currentUserId == s.data.buyerId;
  }

  bool isSeller() {
    final s = _state;
    if (s is! Success<Transaction>) return false;
    return _currentUserId == s.data.sellerId;
  }

  /// Nhãn nút hành động cho bước hiện tại — null nếu không có hành động thủ công.
  String? get actionLabel {
    final s = _state;
    if (s is! Success<Transaction>) return null;
    final step = s.data.escrowStep;
    if (step == null) return null;
    return _actionLabels[step];
  }

  /// User hiện tại có phải là bên cần xác nhận ở bước này không.
  bool get canAct {
    final s = _state;
    if (s is! Success<Transaction>) return false;
    final step = s.data.escrowStep;
    if (step == null) return false;
    final needsBuyer = _actorIsBuyer[step];
    if (needsBuyer == null) return false;
    return needsBuyer ? isBuyer() : isSeller();
  }

  // D4 — advance escrow
  Future<bool> advanceEscrow() async {
    if (_state is! Success<Transaction>) return false;
    _advancing = true;
    _actionError = null;
    notifyListeners();

    final r = await _repo.advanceEscrow(transactionId);
    _advancing = false;

    if (r is ResultSuccess<Transaction>) {
      _state = Success(r.data);
      _syncPaymentPolling(r.data);
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

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
