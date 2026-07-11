import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/create_order_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';

class CreateOrderView extends StatelessWidget {
  final String listingId;
  const CreateOrderView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateOrderViewModel(listingId: listingId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateOrderViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Xác nhận giao dịch'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TradeLinkSpacing.md),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: TradeLinkColors.primaryContainer.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.security_rounded,
                  size: 48,
                  color: TradeLinkColors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              'Quy trình giao dịch an toàn',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            _Step(icon: Icons.credit_card_rounded, text: 'Bạn thanh toán vào hệ thống trung gian'),
            _Step(icon: Icons.lock_outline, text: 'Tiền được giữ an toàn trong escrow'),
            _Step(icon: Icons.local_shipping_outlined, text: 'Người bán giao hàng'),
            _Step(icon: Icons.check_circle_outline, text: 'Bạn nhận hàng & xác nhận → Giải ngân'),
            const SizedBox(height: TradeLinkSpacing.lg),
            // Agreement
            Container(
              padding: const EdgeInsets.all(TradeLinkSpacing.md),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                border: Border.all(color: TradeLinkColors.cardBorder),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: vm.agreed,
                    onChanged: vm.toggleAgree,
                    activeColor: TradeLinkColors.primaryContainer,
                  ),
                  Expanded(
                    child: Text(
                      'Tôi đồng ý với điều khoản giao dịch của TradeLink',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TradeLinkColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            TradeLinkButton.cta(
              label: 'Xác nhận & Tạo giao dịch',
              icon: Icons.check_circle_outline,
              isLoading: vm.state is Loading,
              onPressed: (vm.agreed && vm.state is! Loading)
                  ? () async {
                      final tx = await vm.confirm();
                      if (tx != null && context.mounted) {
                        context.go('${AppPaths.transactionSale}/${tx.id}');
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Step({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TradeLinkColors.primaryContainer.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: TradeLinkColors.primaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: TradeLinkSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TradeLinkColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}