import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/offer_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/send_offer_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';

class SendOfferView extends StatelessWidget {
  final String listingId;
  const SendOfferView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendOfferViewModel(listingId: listingId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SendOfferViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Gửi đề nghị'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Loại đề nghị',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Mua',
                    icon: Icons.shopping_bag_outlined,
                    selected: vm.type == OfferType.buy,
                    onTap: () => vm.setType(OfferType.buy),
                  ),
                ),
                const SizedBox(width: TradeLinkSpacing.sm),
                Expanded(
                  child: _TypeChip(
                    label: 'Trao đổi',
                    icon: Icons.swap_horiz,
                    selected: vm.type == OfferType.trade,
                    onTap: () => vm.setType(OfferType.trade),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.lg),

            if (vm.type == OfferType.buy) ...[
              TextField(
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Giá bạn đề nghị (VNĐ)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                onChanged: vm.setPrice,
              ),
            ] else ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Mô tả món đồ bạn muốn đổi',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: TradeLinkSpacing.md),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tiền bù chênh lệch (VNĐ - tùy chọn)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: TradeLinkSpacing.md),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Lời nhắn',
                hintText: 'Chào bạn, mình quan tâm đến...',
              ),
              maxLines: 3,
              onChanged: vm.setMessage,
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            TradeLinkButton.cta(
              label: 'Gửi đề nghị',
              icon: Icons.send_outlined,
              isLoading: vm.state is Loading,
              onPressed: vm.state is Loading
                  ? null
                  : () async {
                      final ok = await vm.submit();
                      if (ok && context.mounted) context.pop();
                    },
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: TradeLinkColors.onSurfaceVariant,
                ),
                const SizedBox(width: TradeLinkSpacing.xs),
                Expanded(
                  child: Text(
                    'Gửi đề nghị không tạo ràng buộc pháp lý. Giao dịch chỉ được xác nhận khi cả hai bên đồng ý.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: TradeLinkColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.md,
          vertical: TradeLinkSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? TradeLinkColors.primaryContainer.withValues(alpha: 0.08)
              : TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
          border: Border.all(
            color: selected
                ? TradeLinkColors.primaryContainer
                : TradeLinkColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? TradeLinkColors.primaryContainer
                  : TradeLinkColors.onSurfaceVariant,
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? TradeLinkColors.primaryContainer
                    : TradeLinkColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}