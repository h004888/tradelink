import '../../core/result.dart';
import '../../models/transaction_model.dart';

class TransactionRepository {
  final Transaction _mockSale = Transaction(
    id: 'tx-001', type: TransactionType.sale, listingId: 'lst-001',
    listingTitle: 'Sony A7IV Body', buyerId: 'user-002', buyerName: 'Trần Văn B',
    sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi', amount: 42000000,
    escrowStep: EscrowStep.paymentConfirmed, createdAt: DateTime.now().subtract(const Duration(days: 2)),
  );

  final Transaction _mockTrade = Transaction(
    id: 'tx-002', type: TransactionType.trade, listingId: 'lst-002',
    listingTitle: 'iPhone 15 Pro Max', buyerId: 'user-002', buyerName: 'Trần Văn B',
    sellerId: 'user-001', sellerName: 'Nguyễn Minh Khôi',
    partyASent: true, partyBReceived: false, partyBSent: false, partyAReceived: false,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  Future<Result<Transaction>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final tx = id == 'tx-001' ? _mockSale : _mockTrade;
    return ResultSuccess(tx);
  }

  Future<Result<Transaction>> advanceEscrow(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return ResultSuccess(_mockSale);
  }

  Future<Result<Transaction>> confirmTrade(String id, String party, bool sent, bool received) async {
    await Future.delayed(const Duration(seconds: 1));
    return ResultSuccess(_mockTrade);
  }
}
