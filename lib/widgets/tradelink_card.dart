import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Card chuẩn của TradeLink — 2 levels theo DESIGN.md.
/// - `level: surface1` (mặc định): trắng + border 1px + radius 8 — cho list card
/// - `level: surface2`: trắng + soft shadow (DESIGN.md line 153) + radius 12 — cho modal/overlay
class TradeLinkCard extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// surface1 = bordered (default), surface2 = shadowed (cho modal/overlay)
  final TradeLinkCardLevel level;

  const TradeLinkCard({
    super.key,
    required this.child,
    this.header,
    this.padding,
    this.onTap,
    this.level = TradeLinkCardLevel.surface1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = level == TradeLinkCardLevel.surface2
        ? TradeLinkRadii.xl
        : TradeLinkRadii.lg;

    final decoration = level == TradeLinkCardLevel.surface2
        ? BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: TradeLinkShadow.surface2,
          )
        : BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: TradeLinkColors.cardBorder, width: 1),
          );

    final card = Material(
      color: TradeLinkColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: decoration,
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

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: TradeLinkColors.actionBlue.withValues(alpha: 0.06),
        highlightColor: TradeLinkColors.actionBlue.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

enum TradeLinkCardLevel {
  /// Surface 1 — card trong list: trắng + border 1px + radius 8
  surface1,

  /// Surface 2 — modal/overlay/tooltip: trắng + soft shadow + radius 12
  surface2,
}
