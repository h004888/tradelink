import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/transaction_trade_viewmodel.dart';
import '../../widgets/status_badge.dart';

class TransactionTradeView extends StatelessWidget {
  final String transactionId;
  const TransactionTradeView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => TransactionTradeViewModel(transactionId: transactionId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionTradeViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Theo dõi trao đổi')),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Text(m)),
        Success(data: final tx) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              StatusBadge(type: TradeLinkBadgeType.trade, label: 'Giao dịch TRAO ĐỔI - Xác nhận song phương'),
              const SizedBox(height: 16),
              // Both parties
              Row(children: [
                Expanded(child: _PartyCard(name: tx.sellerName, label: 'Bên A', sent: tx.partyASent, received: tx.partyBReceived)),
                const SizedBox(width: 12),
                const Icon(Icons.swap_horiz, size: 32, color: TradeLinkColors.tradeTeal),
                const SizedBox(width: 12),
                Expanded(child: _PartyCard(name: tx.buyerName, label: 'Bên B', sent: tx.partyBSent, received: tx.partyAReceived)),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(TradeLinkSpacing.md),
                decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Quy trình trao đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('1. Mỗi bên gửi đồ cho đối phương\n2. Bấm "Đã gửi đồ"\n3. Khi nhận được đồ, bấm "Đã nhận đồ"\n4. Khi cả 2 bên xác nhận → Hoàn tất', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant, height: 1.6)),
                ]),
              ),
            ]),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _PartyCard extends StatelessWidget {
  final String name, label; final bool? sent, received;
  const _PartyCard({required this.name, required this.label, this.sent, this.received});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
    child: Column(children: [
      Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: TradeLinkColors.surfaceContainerHigh), child: const Icon(Icons.person)),
      const SizedBox(height: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(sent == true ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: sent == true ? TradeLinkColors.successGreen : TradeLinkColors.outlineVariant),
        const SizedBox(width: 4), const Text('Đã gửi', style: TextStyle(fontSize: 11)),
      ]),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(received == true ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: received == true ? TradeLinkColors.successGreen : TradeLinkColors.outlineVariant),
        const SizedBox(width: 4), const Text('Đã nhận', style: TextStyle(fontSize: 11)),
      ]),
    ]),
  );
}
