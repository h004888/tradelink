enum TransactionType { sale, trade }

enum EscrowStep { paymentPending, paymentConfirmed, shipping, delivered, reviewPeriod, released, refunded }

class EscrowStepHelper {
  static String label(EscrowStep s) => switch (s) {
    EscrowStep.paymentPending => 'Chờ thanh toán',
    EscrowStep.paymentConfirmed => 'Đã thanh toán',
    EscrowStep.shipping => 'Đang giao hàng',
    EscrowStep.delivered => 'Đã nhận hàng',
    EscrowStep.reviewPeriod => 'Thời gian đánh giá',
    EscrowStep.released => 'Đã giải ngân',
    EscrowStep.refunded => 'Đã hoàn tiền',
  };

  static String description(EscrowStep s) => switch (s) {
    EscrowStep.paymentPending => 'Người mua đang tiến hành thanh toán vào hệ thống trung gian',
    EscrowStep.paymentConfirmed => 'Tiền đã được giữ an toàn. Người bán vui lòng giao hàng.',
    EscrowStep.shipping => 'Người bán đã gửi hàng. Vui lòng chờ nhận hàng.',
    EscrowStep.delivered => 'Bạn đã nhận được hàng? Xác nhận để giải ngân.',
    EscrowStep.reviewPeriod => 'Đang chờ đánh giá từ hai bên',
    EscrowStep.released => 'Giao dịch hoàn tất! Tiền đã được chuyển cho người bán.',
    EscrowStep.refunded => 'Khiếu nại đã được xử lý: tiền đã được hoàn lại cho người mua.',
  };

  /// Số bước hiển thị trên stepper tuyến tính — 'refunded' là trạng thái rẽ nhánh
  /// riêng (do admin xử lý khiếu nại), không nằm trong luồng tuyến tính này.
  static int get total => EscrowStep.values.length - 1;
}

class Transaction {
  final String id;
  final TransactionType type;
  final String listingId;
  final String listingTitle;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double? amount;
  final EscrowStep? escrowStep;
  final bool? partyASent;
  final bool? partyAReceived;
  final bool? partyBSent;
  final bool? partyBReceived;
  final DateTime createdAt;

  const Transaction({
    required this.id, required this.type, required this.listingId,
    required this.listingTitle, required this.buyerId, required this.buyerName,
    required this.sellerId, required this.sellerName, this.amount, this.escrowStep,
    this.partyASent, this.partyAReceived, this.partyBSent, this.partyBReceived,
    required this.createdAt,
  });

  bool get isCompleted => type == TransactionType.sale ? escrowStep == EscrowStep.released : (partyAReceived == true && partyBReceived == true);
  bool get isRefunded => escrowStep == EscrowStep.refunded;

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        type: j['type'] == 'trade' ? TransactionType.trade : TransactionType.sale,
        listingId: j['listingId']?.toString() ?? '',
        listingTitle: j['listingTitle'] as String? ?? '',
        buyerId: j['buyerId']?.toString() ?? '',
        buyerName: j['buyerName'] as String? ?? '',
        sellerId: j['sellerId']?.toString() ?? '',
        sellerName: j['sellerName'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble(),
        escrowStep: _parseEscrowStep(j['escrowStep'] as String?),
        partyASent: j['partyASent'] as bool?,
        partyAReceived: j['partyAReceived'] as bool?,
        partyBSent: j['partyBSent'] as bool?,
        partyBReceived: j['partyBReceived'] as bool?,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

EscrowStep? _parseEscrowStep(String? s) {
  if (s == null) return null;
  for (final v in EscrowStep.values) {
    if (v.name == s) return v;
  }
  return null;
}
