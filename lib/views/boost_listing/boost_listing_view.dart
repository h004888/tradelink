import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/boost_listing_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/tradelink_text.dart';

class BoostListingView extends StatelessWidget {
  final String listingId;
  const BoostListingView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoostListingViewModel(listingId: listingId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoostListingViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Đẩy tin đăng'),
      body: Padding(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current rank info
            TradeLinkCard(
              padding: const EdgeInsets.all(TradeLinkSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: TradeLinkColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: TradeLinkColors.primaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vị trí hiện tại',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: TradeLinkColors.onSurfaceVariant,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#42 trong danh mục',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: TradeLinkColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              'Chọn gói đẩy tin',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            _PackageCard(
              days: 3,
              price: 20000,
              icon: Icons.local_fire_department,
              selected: vm.selectedDays == 3,
              onTap: () => vm.selectDays(3),
            ),
            const SizedBox(height: TradeLinkSpacing.sm),
            _PackageCard(
              days: 7,
              price: 50000,
              icon: Icons.rocket_launch,
              selected: vm.selectedDays == 7,
              onTap: () => vm.selectDays(7),
              popular: true,
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            // Refresh option
            TradeLinkCard(
              padding: const EdgeInsets.all(TradeLinkSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TradeLinkColors.actionBlue.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.refresh,
                      color: TradeLinkColors.actionBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Làm mới tin',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đưa tin lên đầu feed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TradeLinkColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TradeLinkText.money(
                    '5.000đ',
                    size: 'compact',
                  ),
                ],
              ),
            ),
            const Spacer(),
            TradeLinkButton.cta(
              label: 'Thanh toán ${vm.price}đ',
              icon: Icons.payment_outlined,
              isLoading: vm.state is Loading,
              onPressed: () async {
                final ok = await vm.boost();
                if (ok && context.mounted) context.pop();
              },
            ),
            const SizedBox(height: TradeLinkSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final int days;
  final int price;
  final IconData icon;
  final bool selected;
  final bool popular;
  final VoidCallback onTap;

  const _PackageCard({
    required this.days,
    required this.price,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.popular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(TradeLinkSpacing.md),
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
          border: Border.all(
            color: selected
                ? TradeLinkColors.primaryContainer
                : TradeLinkColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? TradeLinkColors.primaryContainer.withValues(alpha: 0.12)
                    : TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 28,
                color: selected
                    ? TradeLinkColors.primaryContainer
                    : TradeLinkColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: TradeLinkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Đẩy tin $days ngày',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TradeLinkColors.onSurface,
                        ),
                      ),
                      if (popular) ...[
                        const SizedBox(width: TradeLinkSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TradeLinkSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TradeLinkColors.successGreen,
                            borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                          ),
                          child: const Text(
                            'Phổ biến',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tin xuất hiện ở đầu kết quả',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TradeLinkColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TradeLinkSpacing.sm),
            TradeLinkText.money('$price đ', size: 'compact'),
            if (selected) ...[
              const SizedBox(width: TradeLinkSpacing.xs),
              const Icon(
                Icons.check_circle,
                color: TradeLinkColors.primaryContainer,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}