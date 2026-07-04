import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TradeLinkCard extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const TradeLinkCard({
    super.key,
    required this.child,
    this.header,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
          border: Border.all(color: TradeLinkColors.cardBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) ...[
              Padding(
                padding: padding ?? const EdgeInsets.all(TradeLinkSpacing.md),
                child: header,
              ),
              const Divider(height: 1, color: TradeLinkColors.cardDivider),
            ],
            Padding(
              padding: padding ?? const EdgeInsets.all(TradeLinkSpacing.md),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
