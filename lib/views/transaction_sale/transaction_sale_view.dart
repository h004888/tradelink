import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/transaction_sale_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class TransactionSaleView extends StatelessWidget {
  final String transactionId;
  const TransactionSaleView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionSaleViewModel(transactionId: transactionId),
      child: _Body(transactionId: transactionId),
    );
  }
}

class _Body extends StatelessWidget {
  final String transactionId;
  const _Body({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionSaleViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Theo dõi giao dịch',
        subtitle: 'BÁN — Escrow đang giữ tiền',
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.timeline(stepCount: 6),
        Error(message: final m) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được giao dịch',
            message: m,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success(data: final tx) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trust signal — prominent badge
                StatusBadge(
                  type: TradeLinkBadgeType.escrow,
                  label: 'Giao dịch BÁN — Escrow đang hoạt động',
                  prominent: true,
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Hero amount card — TradeLinkCard surface1 + moneyLarge
                TradeLinkCard(
                  padding: const EdgeInsets.all(TradeLinkSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Số tiền giao dịch',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                      ),
                      const SizedBox(height: TradeLinkSpacing.sm),
                      TradeLinkText.money(
                        formatVnd(tx.amount),
                        size: 'large',
                      ),
                      const SizedBox(height: TradeLinkSpacing.sm),
                      const Divider(
                        height: 1,
                        color: TradeLinkColors.cardDivider,
                      ),
                      const SizedBox(height: TradeLinkSpacing.sm),
                      Text(
                        tx.listingTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TradeLinkColors.onSurface,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Section title
                Padding(
                  padding: const EdgeInsets.only(left: TradeLinkSpacing.xs),
                  child: Text(
                    'Tiến trình escrow',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TradeLinkColors.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.md),

                // Escrow Timeline
                ...List.generate(EscrowStepHelper.total, (i) {
                  final step = EscrowStep.values[i];
                  final currentIdx = tx.escrowStep!.index;
                  final isDone = i < currentIdx;
                  final isActive = i == currentIdx;
                  return _TimelineItem(
                    step: step,
                    isDone: isDone,
                    isActive: isActive,
                    isLast: i == EscrowStepHelper.total - 1,
                  );
                }),

                if (tx.escrowStep == EscrowStep.released && vm.targetId() != null) ...[
                  const SizedBox(height: TradeLinkSpacing.lg),
                  TradeLinkButton.cta(
                    label: 'Đánh giá đối tác',
                    icon: Icons.rate_review_outlined,
                    saleContext: false,
                    onPressed: () => context.push(
                      '${AppPaths.review}/$transactionId/${vm.targetId()}',
                    ),
                  ),
                ],
                const SizedBox(height: TradeLinkSpacing.lg),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final EscrowStep step;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? TradeLinkColors.successGreen
        : isActive
            ? TradeLinkColors.primaryContainer
            : TradeLinkColors.outlineVariant;
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? color
                      : TradeLinkColors.surfaceContainerHigh,
                  border: Border.all(
                    color: color,
                    width: isDone || isActive ? 0 : 1.5,
                  ),
                ),
                child: Icon(
                  isDone
                      ? Icons.check
                      : isActive
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                  size: isDone ? 20 : 16,
                  color: isDone || isActive ? Colors.white : color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? TradeLinkColors.successGreen
                        : TradeLinkColors.cardDivider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: TradeLinkSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : TradeLinkSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EscrowStepHelper.label(step),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive || isDone
                          ? TradeLinkColors.onSurface
                          : TradeLinkColors.onSurfaceVariant,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: TradeLinkSpacing.xs),
                    Text(
                      EscrowStepHelper.description(step),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TradeLinkColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}