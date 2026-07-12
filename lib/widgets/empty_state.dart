import 'package:flutter/material.dart';

import '../utils/theme.dart';
import 'tradelink_button.dart';

/// Empty state chuẩn của TradeLink.
/// Dùng cho: list rỗng (chưa có giao dịch, chưa có listing), error không retry được,
/// onboarding hint cho người dùng mới.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional secondary action — link phụ (vd: "Xem hướng dẫn")
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Trust tone: thay vì outlineVariant icon, dùng màu brand để tạo cảm giác "an toàn"
  final bool useBrandColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.useBrandColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = useBrandColor
        ? TradeLinkColors.primaryContainer.withValues(alpha: 0.6)
        : TradeLinkColors.outlineVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TradeLinkSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: TradeLinkColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01 * 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: TradeLinkColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TradeLinkSpacing.lg),
              SizedBox(
                width: 220,
                child: TradeLinkButton.cta(
                  label: actionLabel!,
                  onPressed: onAction,
                  fullWidth: true,
                ),
              ),
            ],
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: TradeLinkSpacing.xs),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: TradeLinkColors.actionBlue,
                ),
                child: Text(secondaryLabel!),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant chuyên biệt cho transaction rỗng — guide user đến action chính.
class TransactionEmptyState extends StatelessWidget {
  final String actionLabel;
  final VoidCallback onAction;
  final bool isSeller;

  const TransactionEmptyState({
    super.key,
    required this.actionLabel,
    required this.onAction,
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = isSeller
        ? 'Chưa có giao dịch nào'
        : 'Chưa có đơn hàng nào';
    final message = isSeller
        ? 'Khi có người mua thanh toán qua escrow, giao dịch sẽ hiển thị ở đây. Bạn có thể đăng tin để bắt đầu.'
        : 'Khám phá các sản phẩm đang được đăng bán. Khi bạn thanh toán qua escrow, đơn hàng sẽ hiển thị ở đây.';

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      secondaryLabel: isSeller ? 'Tìm hiểu về escrow' : null,
      onSecondary: isSeller ? () {} : null,
      useBrandColor: true,
    );
  }
}

/// Variant cho listing rỗng — guide seller đăng tin đầu tiên.
class ListingEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const ListingEmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.add_business_outlined,
      title: 'Chưa có tin đăng nào',
      message: 'Đăng tin đầu tiên để bắt đầu bán hoặc trao đổi. Mọi giao dịch đều được bảo vệ bởi escrow.',
      actionLabel: 'Đăng tin ngay',
      onAction: onCreate,
      secondaryLabel: 'Xem hướng dẫn đăng tin',
      onSecondary: () {},
      useBrandColor: true,
    );
  }
}