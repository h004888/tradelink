import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/listing_detail_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/tradelink_text.dart';

class ListingDetailView extends StatelessWidget {
  final String listingId;
  const ListingDetailView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListingDetailViewModel(listingId: listingId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ListingDetailViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Chi tiết tin đăng'),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.detail(),
        Error(message: final m) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được tin đăng',
            message: m,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success(data: final l) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image placeholder — dùng TradeLinkCard surface1 + extra radius cho hero
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 56,
                        color: TradeLinkColors.outlineVariant,
                      ),
                      const SizedBox(height: TradeLinkSpacing.xs),
                      Text(
                        'Hình ảnh sản phẩm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Stats row — dùng divider dọc để rõ separation
                TradeLinkCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TradeLinkSpacing.md,
                    vertical: TradeLinkSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'Lượt xem', value: '${l.views}'),
                      Container(
                        width: 1,
                        height: 32,
                        color: TradeLinkColors.cardDivider,
                      ),
                      _Stat(label: 'Quan tâm', value: '${l.interests}'),
                      Container(
                        width: 1,
                        height: 32,
                        color: TradeLinkColors.cardDivider,
                      ),
                      _Stat(label: 'Đã lưu', value: '${l.saves}'),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                // Status + Type badges
                Wrap(
                  spacing: TradeLinkSpacing.xs,
                  runSpacing: TradeLinkSpacing.xs,
                  children: [
                    StatusBadge(
                      type: TradeLinkBadgeType.success,
                      label: 'Đang hiển thị',
                      prominent: true,
                    ),
                    StatusBadge(
                      type: l.type == ListingType.trade
                          ? TradeLinkBadgeType.trade
                          : TradeLinkBadgeType.escrow,
                      label: l.type == ListingType.trade ? 'Trao đổi' : 'Bán qua escrow',
                      prominent: true,
                    ),
                  ],
                ),
                const SizedBox(height: TradeLinkSpacing.md),

                // Title
                Text(
                  l.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01 * 22,
                    height: 1.25,
                  ),
                ),

                // Money — TradeLinkText.money đảm bảo tabular-nums
                if (l.price != null) ...[
                  const SizedBox(height: TradeLinkSpacing.sm),
                  TradeLinkText.money(
                    l.priceFormatted,
                    color: TradeLinkColors.saleBlue,
                    size: 'large',
                  ),
                ],

                const SizedBox(height: TradeLinkSpacing.md),
                const Divider(height: 1, color: TradeLinkColors.cardDivider),
                const SizedBox(height: TradeLinkSpacing.md),

                // Description
                Text(
                  'Mô tả chi tiết',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.xs),
                Text(
                  l.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TradeLinkColors.onSurface,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: TradeLinkSpacing.xl),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TradeLinkButton.secondary(
                        label: 'Chỉnh sửa',
                        icon: Icons.edit_outlined,
                        onPressed: () => vm.edit(context),
                      ),
                    ),
                    const SizedBox(width: TradeLinkSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: TradeLinkButton.cta(
                        label: 'Đẩy tin nổi bật',
                        icon: Icons.trending_up,
                        onPressed: () => vm.boost(context),
                        saleContext: l.type == ListingType.sale,
                      ),
                    ),
                  ],
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: TradeLinkColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}