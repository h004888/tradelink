import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/transaction_list_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionListViewModel(),
      child: const _TransactionListBody(),
    );
  }
}

class _TransactionListBody extends StatelessWidget {
  const _TransactionListBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Giao dịch', style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
        backgroundColor: TradeLinkColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.list(),
        Error(message: final m, retryable: true) => Center(
            child: EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được giao dịch',
              message: m,
              actionLabel: 'Thử lại',
              onAction: vm.load,
            ),
          ),
        Success(data: final items) when items.isEmpty => Center(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có giao dịch nào',
              message: 'Khi bạn mua hoặc bán qua escrow, giao dịch sẽ hiển thị ở đây.',
              actionLabel: 'Khám phá sản phẩm',
              onAction: () => context.go('/home'),
            ),
          ),
        Success(data: final items) => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) => _TransactionTile(
              transaction: items[i],
              onTap: () {
                final path = items[i].type == TransactionType.sale
                    ? '/transactions/sale/${items[i].id}'
                    : '/transactions/trade/${items[i].id}';
                context.push(path);
              },
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionTile({required this.transaction, required this.onTap});

  TradeLinkBadgeType _badgeType(EscrowStep? step) {
    if (step == null) return TradeLinkBadgeType.pending;
    return switch (step) {
      EscrowStep.paymentPending => TradeLinkBadgeType.pending,
      EscrowStep.paymentConfirmed => TradeLinkBadgeType.escrow,
      EscrowStep.shipping => TradeLinkBadgeType.info,
      EscrowStep.delivered => TradeLinkBadgeType.info,
      EscrowStep.reviewPeriod => TradeLinkBadgeType.pending,
      EscrowStep.released => TradeLinkBadgeType.success,
    };
  }

  String _escrowLabel(EscrowStep? step) {
    if (step == null) return 'Khởi tạo';
    return EscrowStepHelper.label(step);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: transaction.type == TransactionType.trade
              ? TradeLinkColors.tradeTeal.withValues(alpha: 0.1)
              : TradeLinkColors.saleBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          transaction.type == TransactionType.trade
              ? Icons.swap_horiz_rounded
              : Icons.shopping_bag_outlined,
          color: transaction.type == TransactionType.trade
              ? TradeLinkColors.tradeTeal
              : TradeLinkColors.saleBlue,
          size: 22,
        ),
      ),
      title: Text(
        transaction.listingTitle,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          StatusBadge(
            type: _badgeType(transaction.escrowStep),
            label: _escrowLabel(transaction.escrowStep),
          ),
          const SizedBox(width: 8),
          Text(
            formatVnd(transaction.amount),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: transaction.type == TransactionType.trade
                  ? TradeLinkColors.tradeTeal
                  : TradeLinkColors.saleBlue,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: TradeLinkColors.onSurfaceVariant),
    );
  }
}
