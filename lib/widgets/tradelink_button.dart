import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TradeLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool saleContext;
  final bool isCta;

  const TradeLinkButton._({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.saleContext = true,
    this.isCta = false,
  });

  /// Filled button: Sale = deep blue, Trade = teal
  factory TradeLinkButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool saleContext = true,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      saleContext: saleContext,
      isCta: false,
    );
  }

  /// Outlined button
  factory TradeLinkButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      isCta: false,
    );
  }

  /// CTA button — larger padding for high-importance actions
  factory TradeLinkButton.cta({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool saleContext = true,
  }) {
    return TradeLinkButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      saleContext: saleContext,
      isCta: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = saleContext ? TradeLinkColors.saleBlue : TradeLinkColors.tradeTeal;

    if (icon != null && onPressed != null) {
      // Secondary style — outlined
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: EdgeInsets.symmetric(
            horizontal: TradeLinkSpacing.lg,
            vertical: isCta ? TradeLinkSpacing.md : TradeLinkSpacing.sm,
          ),
        ),
      );
    }

    // Primary or CTA — filled
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.lg,
          vertical: isCta ? TradeLinkSpacing.md : TradeLinkSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        ),
      ),
      child: Text(label),
    );
  }
}
