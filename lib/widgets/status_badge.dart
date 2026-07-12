import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum TradeLinkBadgeType { escrow, trade, verification, dispute, success, pending, info }

/// Status badge chuẩn của TradeLink — DESIGN.md gọi là "Trust-Indicators".
/// - default: chip nhỏ 12px/w500 — cho list cards, secondary info
/// - prominent: 14px/w700, icon to — cho transaction detail, escrow state, hero trust signals
class StatusBadge extends StatelessWidget {
  final TradeLinkBadgeType type;
  final String label;
  final bool prominent;

  const StatusBadge({
    super.key,
    required this.type,
    required this.label,
    this.prominent = false,
  });

  Color _bgColor() {
    return switch (type) {
      TradeLinkBadgeType.escrow => TradeLinkColors.saleBlue.withValues(alpha: 0.10),
      TradeLinkBadgeType.trade => TradeLinkColors.tradeTeal.withValues(alpha: 0.10),
      TradeLinkBadgeType.verification => TradeLinkColors.actionBlue.withValues(alpha: 0.10),
      TradeLinkBadgeType.dispute => TradeLinkColors.disputeRed.withValues(alpha: 0.10),
      TradeLinkBadgeType.success => TradeLinkColors.successGreen.withValues(alpha: 0.10),
      TradeLinkBadgeType.pending => TradeLinkColors.escrowAmber.withValues(alpha: 0.12),
      TradeLinkBadgeType.info => TradeLinkColors.actionBlue.withValues(alpha: 0.10),
    };
  }

  Color _fgColor() {
    return switch (type) {
      TradeLinkBadgeType.escrow => TradeLinkColors.saleBlue,
      TradeLinkBadgeType.trade => TradeLinkColors.tradeTeal,
      TradeLinkBadgeType.verification => TradeLinkColors.actionBlue,
      TradeLinkBadgeType.dispute => TradeLinkColors.disputeRed,
      TradeLinkBadgeType.success => TradeLinkColors.successGreen,
      TradeLinkBadgeType.pending => TradeLinkColors.escrowAmber,
      TradeLinkBadgeType.info => TradeLinkColors.actionBlue,
    };
  }

  IconData _icon() {
    return switch (type) {
      TradeLinkBadgeType.escrow => Icons.lock_outline,
      TradeLinkBadgeType.trade => Icons.swap_horiz,
      TradeLinkBadgeType.verification => Icons.verified_outlined,
      TradeLinkBadgeType.dispute => Icons.warning_amber_outlined,
      TradeLinkBadgeType.success => Icons.check_circle_outline,
      TradeLinkBadgeType.pending => Icons.hourglass_top_outlined,
      TradeLinkBadgeType.info => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fgColor();
    final bg = _bgColor();
    final iconSize = prominent ? 16.0 : 14.0;
    final fontSize = prominent ? 14.0 : 12.0;
    final fontWeight = prominent ? FontWeight.w700 : FontWeight.w500;
    final hPad = prominent ? TradeLinkSpacing.sm : TradeLinkSpacing.xs;
    final vPad = prominent ? TradeLinkSpacing.xs : TradeLinkSpacing.base;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TradeLinkRadii.full),
        border: prominent
            ? Border.all(color: fg.withValues(alpha: 0.18), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: iconSize, color: fg),
          SizedBox(width: prominent ? TradeLinkSpacing.xs : 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fg,
                letterSpacing: prominent ? 0.2 : 0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}