enum TransactionType { sale, trade }

enum EscrowStep { paymentPending, paymentConfirmed, shipping, delivered, reviewPeriod, released }

class EscrowStepHelper {
  static String label(EscrowStep s) => switch (s) {
    EscrowStep.paymentPending => 'Chờ thanh toán',
    EscrowStep.paymentConfirmed => 'Đã thanh toán',
    EscrowStep.shipping => 'Đang giao hàng',
    EscrowStep.delivered => 'Đã nhận hàng',
    EscrowStep.reviewPeriod => 'Thời gian đánh giá',
    EscrowStep.released => 'Đã giải ngân',
  };

  static String description(EscrowStep s) => switch (s) {
    EscrowStep.paymentPending => 'Người mua đang tiến hành thanh toán vào hệ thống trung gian',
    EscrowStep.paymentConfirmed => 'Tiền đã được giữ an toàn. Người bán vui lòng giao hàng.',
    EscrowStep.shipping => 'Người bán đã gửi hàng. Vui lòng chờ nhận hàng.',
    EscrowStep.delivered => 'Bạn đã nhận được hàng? Xác nhận để giải ngân.',
    EscrowStep.reviewPeriod => 'Đang chờ đánh giá từ hai bên',
    EscrowStep.released => 'Giao dịch hoàn tất! Tiền đã được chuyển cho người bán.',
  };

  static int get total => EscrowStep.values.length;
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
}
