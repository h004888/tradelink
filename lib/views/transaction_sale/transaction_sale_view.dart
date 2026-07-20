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
      appBar: TradeLinkAppBar(
        title: 'Theo dõi giao dịch',
        subtitle: 'BÁN — Escrow đang giữ tiền',
        actions: [
          IconButton(
            icon: const Icon(Icons.report_gmailerrorred_outlined),
            tooltip: 'Mở khiếu nại',
            onPressed: () => context.push('${AppPaths.dispute}/$transactionId'),
          ),
        ],
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
        Success(data: final tx) when tx.escrowStep == null =>
          // Phòng vệ: giao dịch TRADE bị điều hướng nhầm vào màn Bán (vd deep-link cũ,
          // hoặc "Mua an toàn" bấm nhầm trên tin trade) — escrowStep null nghĩa là
          // đây không phải giao dịch sale, tự chuyển sang đúng màn thay vì crash.
          Builder(builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('${AppPaths.transactionTrade}/$transactionId');
            });
            return const LoadingSkeleton.timeline(stepCount: 6);
          }),
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

                // Trường hợp rẽ nhánh: admin đã xử lý khiếu nại → hoàn tiền.
                // Không thuộc luồng escrow tuyến tính nên hiện banner riêng thay vì stepper.
                if (tx.escrowStep == EscrowStep.refunded)
                  Container(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    decoration: BoxDecoration(
                      color: TradeLinkColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                      border: Border.all(color: TradeLinkColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_return_outlined, color: TradeLinkColors.error),
                        const SizedBox(width: TradeLinkSpacing.sm),
                        Expanded(
                          child: Text(
                            EscrowStepHelper.description(EscrowStep.refunded),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TradeLinkColors.error),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
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

                  if (tx.escrowStep == EscrowStep.paymentPending) ...[
                    const SizedBox(height: TradeLinkSpacing.sm),
                    _PaymentQrSection(vm: vm, isBuyer: vm.isBuyer()),
                  ],

                  if (vm.actionLabel != null) ...[
                    const SizedBox(height: TradeLinkSpacing.sm),
                    if (vm.canAct)
                      TradeLinkButton.cta(
                        label: vm.actionLabel!,
                        icon: Icons.check_circle_outline,
                        isLoading: vm.isAdvancing,
                        onPressed: vm.isAdvancing
                            ? null
                            : () async {
                                final ok = await vm.advanceEscrow();
                                if (!ok && context.mounted && vm.actionError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(vm.actionError!)),
                                  );
                                }
                              },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                        decoration: BoxDecoration(
                          color: TradeLinkColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.hourglass_empty,
                              size: 16, color: TradeLinkColors.onSurfaceVariant),
                            const SizedBox(width: TradeLinkSpacing.xs),
                            Expanded(
                              child: Text(
                                'Đang chờ ${vm.isBuyer() ? "người bán" : "người mua"} xác nhận bước này',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],

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

/// Hiện QR chuyển khoản SePay cho buyer khi ở bước 'paymentPending'.
/// Không có nút bấm tay — hệ thống tự nhận diện thanh toán qua webhook và
/// ViewModel tự poll để cập nhật ngay khi được xác nhận.
class _PaymentQrSection extends StatelessWidget {
  final TransactionSaleViewModel vm;
  final bool isBuyer;
  const _PaymentQrSection({required this.vm, required this.isBuyer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isBuyer) {
      return Container(
        padding: const EdgeInsets.all(TradeLinkSpacing.sm),
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty, size: 16, color: TradeLinkColors.onSurfaceVariant),
            const SizedBox(width: TradeLinkSpacing.xs),
            Expanded(
              child: Text(
                'Đang chờ người mua thanh toán qua chuyển khoản',
                style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return switch (vm.paymentInfo) {
      Loading() => const Center(
          child: Padding(
            padding: EdgeInsets.all(TradeLinkSpacing.md),
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      Error(message: final m) => Container(
          padding: const EdgeInsets.all(TradeLinkSpacing.sm),
          decoration: BoxDecoration(
            color: TradeLinkColors.errorContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
          ),
          child: Text(m, style: const TextStyle(color: TradeLinkColors.error, fontSize: 13)),
        ),
      Success(data: final info) => TradeLinkCard(
          padding: const EdgeInsets.all(TradeLinkSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Quét mã để thanh toán',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
                child: Image.network(
                  info.qrUrl,
                  width: 220,
                  height: 220,
                  errorBuilder: (_, _, _) => Container(
                    width: 220,
                    height: 220,
                    color: TradeLinkColors.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: const Icon(Icons.qr_code_2, size: 48, color: TradeLinkColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
              Text(
                '${info.bankAccountName} • ${info.bankAccountNumber}',
                style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                'Nội dung CK: ${info.paymentCode}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TradeLinkSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: TradeLinkSpacing.xs),
                  Text(
                    'Đang chờ xác nhận thanh toán tự động...',
                    style: theme.textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}