import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/offer_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/offers_list_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/tradelink_text.dart';

class OffersListView extends StatelessWidget {
  const OffersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OffersListViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OffersListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Đề nghị',
        subtitle: vm.scope == OffersScope.sent
            ? 'Đề nghị bạn đã gửi'
            : 'Đề nghị bạn đã nhận',
      ),
      body: Column(
        children: [
          // Tab toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.md,
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(TradeLinkRadii.full),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ScopeTab(
                      label: 'Đã gửi',
                      icon: Icons.send_outlined,
                      selected: vm.scope == OffersScope.sent,
                      onTap: () => vm.switchScope(OffersScope.sent),
                    ),
                  ),
                  Expanded(
                    child: _ScopeTab(
                      label: 'Đã nhận',
                      icon: Icons.inbox_outlined,
                      selected: vm.scope == OffersScope.received,
                      onTap: () => vm.switchScope(OffersScope.received),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (vm.isLoading) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (vm.errorMessage != null) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Có lỗi xảy ra',
                  message: vm.errorMessage!,
                  actionLabel: 'Thử lại',
                  onAction: vm.load,
                );
              }
              if (vm.items.isEmpty) {
                return EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'Chưa có đề nghị',
                  message: vm.scope == OffersScope.sent
                      ? 'Các đề nghị bạn gửi cho người bán sẽ hiển thị ở đây.'
                      : 'Khi có người mua gửi đề nghị, bạn sẽ thấy ở đây.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                itemCount: vm.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TradeLinkSpacing.sm),
                itemBuilder: (_, i) {
                  final o = vm.items[i];
                  final isTrade = o.type == OfferType.trade;
                  return TradeLinkCard(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (isTrade
                                        ? TradeLinkColors.tradeTeal
                                        : TradeLinkColors.saleBlue)
                                    .withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isTrade
                                    ? Icons.swap_horiz
                                    : Icons.shopping_bag_outlined,
                                size: 18,
                                color: isTrade
                                    ? TradeLinkColors.tradeTeal
                                    : TradeLinkColors.saleBlue,
                              ),
                            ),
                            const SizedBox(width: TradeLinkSpacing.sm),
                            Expanded(
                              child: Text(
                                isTrade
                                    ? 'Đề nghị trao đổi'
                                    : 'Đề nghị mua',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              _fmtDate(o.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: TradeLinkColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (o.listingTitle != null) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Text(
                            'Tin: ${o.listingTitle}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (o.price != null) ...[
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Row(
                            children: [
                              Text(
                                'Giá đề nghị: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                              ),
                              TradeLinkText.money(
                                '${o.price!.toStringAsFixed(0)} đ',
                                size: 'compact',
                              ),
                            ],
                          ),
                        ],
                        if (o.tradeItemDescription != null) ...[
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Text(
                            'Trao đổi: ${o.tradeItemDescription}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (o.message.isNotEmpty) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                            decoration: BoxDecoration(
                              color: TradeLinkColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
                            ),
                            child: Text(
                              o.message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TradeLinkColors.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        if (o.buyerName != null) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Text(
                            'Từ: ${o.buyerName}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _ScopeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ScopeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? TradeLinkColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TradeLinkRadii.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? TradeLinkColors.primaryContainer
                  : TradeLinkColors.onSurfaceVariant,
            ),
            const SizedBox(width: TradeLinkSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? TradeLinkColors.primaryContainer
                    : TradeLinkColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}