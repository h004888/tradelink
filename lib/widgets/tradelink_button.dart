import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum TradeLinkButtonVariant { primary, secondary, cta }

/// Button chuẩn của TradeLink.
/// - primary/secondary: dùng cho hành động thường (height 44)
/// - cta: dùng cho hành động quan trọng nhất trên màn hình (height 56, font 16/w700)
/// Sale context = Deep Blue (#1A365D); Trade context = Teal (#065F46).
class TradeLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool saleContext;
  final TradeLinkButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;

  const TradeLinkButton._({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.saleContext = true,
    this.variant = TradeLinkButtonVariant.primary,
    this.fullWidth = false,
    this.isLoading = false,
  });

  /// Filled button — mặc định.
  factory TradeLinkButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool saleContext = true,
    bool fullWidth = false,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      saleContext: saleContext,
      variant: TradeLinkButtonVariant.primary,
      fullWidth: fullWidth,
    );
  }

  /// Outlined button — secondary action.
  factory TradeLinkButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool saleContext = true,
    bool fullWidth = false,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      saleContext: saleContext,
      variant: TradeLinkButtonVariant.secondary,
      fullWidth: fullWidth,
    );
  }

  /// CTA button — lớn hơn, dùng cho hành động chính của màn hình (vd: "Đăng nhập", "Xác nhận thanh toán").
  factory TradeLinkButton.cta({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool saleContext = true,
    bool fullWidth = true,
    bool isLoading = false,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      saleContext: saleContext,
      variant: TradeLinkButtonVariant.cta,
      fullWidth: fullWidth,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = saleContext ? TradeLinkColors.saleBlue : TradeLinkColors.tradeTeal;
    final disabled = onPressed == null;
    final isCta = variant == TradeLinkButtonVariant.cta;

    // ── Heights: CTA=56, primary/secondary=44 ──
    final vPad = isCta ? TradeLinkSpacing.md : TradeLinkSpacing.sm;
    final hPad = isCta ? TradeLinkSpacing.lg : TradeLinkSpacing.lg;
    final fontSize = isCta ? 16.0 : 15.0;
    final fontWeight = isCta ? FontWeight.w700 : FontWeight.w600;
    final iconSize = isCta ? 20.0 : 18.0;

    final baseTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
    );

    final buttonChild = isLoading
        ? SizedBox(
            width: isCta ? 22 : 18,
            height: isCta ? 22 : 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == TradeLinkButtonVariant.secondary ? color : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize),
                const SizedBox(width: TradeLinkSpacing.xs),
              ],
              Text(label, style: baseTextStyle),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isCta ? TradeLinkRadii.md : TradeLinkRadii.xs),
      side: variant == TradeLinkButtonVariant.secondary
          ? BorderSide(color: color, width: 1.5)
          : BorderSide.none,
    );

    final btn = Material(
      color: variant == TradeLinkButtonVariant.secondary
          ? Colors.transparent
          : (disabled ? color.withValues(alpha: 0.4) : color),
      shape: shape,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: shape.borderRadius as BorderRadius?,
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Container(
          height: isCta ? 56 : null,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: baseTextStyle.copyWith(
              color: variant == TradeLinkButtonVariant.secondary
                  ? (disabled ? color.withValues(alpha: 0.4) : color)
                  : Colors.white,
            ),
            child: buttonChild,
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}