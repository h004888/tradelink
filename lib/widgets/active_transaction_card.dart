import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/theme.dart';

/// Card hiển thị giao dịch escrow đang active trên Home page.
///
/// Hiển thị:
/// - Tên sản phẩm + số tiền
/// - Progress bar 6 bước escrow
/// - Trạng thái hiện tại + label
/// - CTA khi user cần hành động (nhận hàng)
///
/// States:
/// - Loading → skeleton shimmer
/// - Empty (ko có giao dịch hoặc tất cả released) → SizedBox.shrink
/// - Active transaction → card đầy đủ
class ActiveTransactionCard extends StatelessWidget {
  final Transaction? transaction;
  final bool isLoading;
  final VoidCallback? onTap;

  const ActiveTransactionCard({
    super.key,
    this.transaction,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _TransactionCardSkeleton();

    final tx = transaction;
    if (tx == null || tx.escrowStep == EscrowStep.released) {
      return const SizedBox.shrink();
    }

    final step = tx.escrowStep ?? EscrowStep.paymentPending;
    final needsAction = step == EscrowStep.delivered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TradeLinkColors.surface,
            borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
            border: Border.all(color: TradeLinkColors.borderSubtle, width: 1),
            boxShadow: TradeLinkShadow.medium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: escrow icon + title + amount
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: TradeLinkColors.paymentHeld.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 20,
                      color: TradeLinkColors.paymentHeld,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.listingTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TradeLinkColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${EscrowStepHelper.label(step)} • ${EscrowStepHelper.description(step)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TradeLinkColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tx.amount != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${tx.amount!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TradeLinkColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              _EscrowProgressBar(currentStep: step),
              // CTA nếu cần hành động
              if (needsAction) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradeLinkColors.primary,
                      foregroundColor: TradeLinkColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Xác nhận đã nhận hàng'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress bar 6 bước escrow — dots nối bằng đường kẻ.
class _EscrowProgressBar extends StatelessWidget {
  final EscrowStep currentStep;

  const _EscrowProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = EscrowStep.values;
    final current = currentStep.index;

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Connector line
              final before = i ~/ 2;
              return Expanded(
                child: Container(
                  height: 2,
                  color: before < current
                      ? TradeLinkColors.trustTeal
                      : TradeLinkColors.neutral,
                ),
              );
            }
            // Dot
            final idx = i ~/ 2;
            final color = idx < current
                ? TradeLinkColors.trustTeal
                : idx == current
                    ? TradeLinkColors.primary
                    : TradeLinkColors.neutral;
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(steps.length, (i) {
            final label = switch (i) {
              0 => 'TT',
              1 => 'Giữ tiền',
              2 => 'Gửi hàng',
              3 => 'Nhận hàng',
              4 => 'Đánh giá',
              5 => 'Hoàn tất',
              _ => '',
            };
            final isCurrent = i == current;
            return Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? TradeLinkColors.primary
                      : i < current
                          ? TradeLinkColors.trustTeal
                          : TradeLinkColors.textMuted,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Skeleton shimmer placeholder cho ActiveTransactionCard
class _TransactionCardSkeleton extends StatelessWidget {
  const _TransactionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TradeLinkColors.surface,
          borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
          border: Border.all(color: TradeLinkColors.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 180,
                        decoration: BoxDecoration(
                          color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(11, (i) {
                if (i.isOdd) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: TradeLinkColors.surfaceContainerHigh,
                    ),
                  );
                }
                return Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
