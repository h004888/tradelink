import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/transaction_sale_viewmodel.dart';
import '../../widgets/status_badge.dart';

class TransactionSaleView extends StatelessWidget {
  final String transactionId;
  const TransactionSaleView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => TransactionSaleViewModel(transactionId: transactionId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionSaleViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Theo dõi giao dịch')),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Text(m)),
        Success(data: final tx) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              StatusBadge(type: TradeLinkBadgeType.escrow, label: 'Giao dịch BÁN - Escrow'),
              const SizedBox(height: 16),
              // Item + amount
              Container(
                padding: const EdgeInsets.all(TradeLinkSpacing.md),
                decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
                child: Column(children: [
                  Text(tx.listingTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${tx.amount?.toStringAsFixed(0) ?? "---"} VNĐ', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue)),
                ]),
              ),
              const SizedBox(height: 20),
              // Escrow Timeline
              ...List.generate(EscrowStepHelper.total, (i) {
                final step = EscrowStep.values[i];
                final currentIdx = tx.escrowStep!.index;
                final isDone = i < currentIdx;
                final isActive = i == currentIdx;
                return _TimelineItem(step: step, isDone: isDone, isActive: isActive, isLast: i == EscrowStepHelper.total - 1);
              }),
            ]),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final EscrowStep step; final bool isDone, isActive, isLast;
  const _TimelineItem({required this.step, required this.isDone, required this.isActive, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = isDone ? TradeLinkColors.successGreen : isActive ? TradeLinkColors.primaryContainer : TradeLinkColors.outlineVariant;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: isDone ? 1.0 : 0.15)), child: Icon(isDone ? Icons.check : isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 16, color: color)),
          if (!isLast) Expanded(child: Container(width: 2, color: isDone ? TradeLinkColors.successGreen : TradeLinkColors.outlineVariant)),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(EscrowStepHelper.label(step), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isActive ? TradeLinkColors.onSurface : TradeLinkColors.onSurfaceVariant)),
            if (isActive) ...[const SizedBox(height: 2), Text(EscrowStepHelper.description(step), style: const TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant))],
          ]),
        )),
      ]),
    );
  }
}
