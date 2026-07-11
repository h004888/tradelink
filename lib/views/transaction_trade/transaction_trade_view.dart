import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/transaction_trade_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class TransactionTradeView extends StatelessWidget {
  final String transactionId;
  const TransactionTradeView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionTradeViewModel(transactionId: transactionId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionTradeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Theo dõi trao đổi',
        subtitle: 'TRAO ĐỔI — Xác nhận song phương',
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.hero(),
        Error(message: final m) => EmptyState(
            icon: Icons.swap_horiz,
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
                StatusBadge(
                  type: TradeLinkBadgeType.trade,
                  label: 'Giao dịch TRAO ĐỔI — Xác nhận song phương',
                  prominent: true,
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Both parties
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _PartyCard(
                        name: tx.sellerName,
                        label: 'Bên A',
                        sent: tx.partyASent,
                        received: tx.partyBReceived,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TradeLinkColors.tradeTeal.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.swap_horiz,
                        size: 20,
                        color: TradeLinkColors.tradeTeal,
                      ),
                    ),
                    Expanded(
                      child: _PartyCard(
                        name: tx.buyerName,
                        label: 'Bên B',
                        sent: tx.partyBSent,
                        received: tx.partyAReceived,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Process info card
                TradeLinkCard(
                  padding: const EdgeInsets.all(TradeLinkSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quy trình trao đổi',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: TradeLinkSpacing.sm),
                      Text(
                        '1. Mỗi bên gửi đồ cho đối phương\n'
                        '2. Bấm "Đã gửi đồ"\n'
                        '3. Khi nhận được đồ, bấm "Đã nhận đồ"\n'
                        '4. Khi cả 2 bên xác nhận → Hoàn tất',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _PartyCard extends StatelessWidget {
  final String name;
  final String label;
  final bool? sent;
  final bool? received;
  const _PartyCard({
    required this.name,
    required this.label,
    this.sent,
    this.received,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.sm),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.surfaceContainerHigh,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
              color: TradeLinkColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.xs),
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: TradeLinkColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.sm),
          _StatusRow(icon: Icons.upload_outlined, label: 'Đã gửi', done: sent == true),
          const SizedBox(height: 4),
          _StatusRow(icon: Icons.download_outlined, label: 'Đã nhận', done: received == true),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  const _StatusRow({required this.icon, required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? TradeLinkColors.successGreen : TradeLinkColors.outlineVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: done ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}