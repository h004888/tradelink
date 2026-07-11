import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// AppBar chuẩn của TradeLink — DESIGN.md "Surface Level 0/1", tonal layer,
/// không heavy shadow. Title dùng titleLarge (28/w700) để có presence rõ ràng.
class TradeLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBottomBorder;

  /// Optional subtitle xuất hiện dưới title — dùng cho màn hình có context (vd: "Giao dịch BÁN").
  final String? subtitle;

  const TradeLinkAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBottomBorder = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return AppBar(
      backgroundColor: TradeLinkColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: TradeLinkSpacing.md,
      leading: leading,
      actions: actions,
      shape: showBottomBorder
          ? const Border(
              bottom: BorderSide(
                color: TradeLinkColors.cardDivider,
                width: 1,
              ),
            )
          : null,
      title: hasSubtitle
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  @override
  Size get preferredSize {
    // Tăng chiều cao khi có subtitle để không bị cắt
    return Size.fromHeight(subtitle != null && subtitle!.isNotEmpty
        ? kToolbarHeight + 24
        : kToolbarHeight);
  }
}