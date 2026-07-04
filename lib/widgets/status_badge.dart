import 'package:flutter/material.dart';
import '../utils/theme.dart';

enum TradeLinkBadgeType { escrow, trade, verification, dispute, success }

class StatusBadge extends StatelessWidget {
  final TradeLinkBadgeType type;
  final String label;

  const StatusBadge({
    super.key,
    required this.type,
    required this.label,
  });

  Color _bgColor() {
    return switch (type) {
      TradeLinkBadgeType.escrow => TradeLinkColors.saleBlue.withValues(alpha: 0.10),
      TradeLinkBadgeType.trade => TradeLinkColors.tradeTeal.withValues(alpha: 0.10),
      TradeLinkBadgeType.verification => TradeLinkColors.actionBlue.withValues(alpha: 0.10),
      TradeLinkBadgeType.dispute => TradeLinkColors.disputeRed.withValues(alpha: 0.10),
      TradeLinkBadgeType.success => TradeLinkColors.successGreen.withValues(alpha: 0.10),
    };
  }

  Color _fgColor() {
    return switch (type) {
      TradeLinkBadgeType.escrow => TradeLinkColors.saleBlue,
      TradeLinkBadgeType.trade => TradeLinkColors.tradeTeal,
      TradeLinkBadgeType.verification => TradeLinkColors.actionBlue,
      TradeLinkBadgeType.dispute => TradeLinkColors.disputeRed,
      TradeLinkBadgeType.success => TradeLinkColors.successGreen,
    };
  }

  IconData _icon() {
    return switch (type) {
      TradeLinkBadgeType.escrow => Icons.lock,
      TradeLinkBadgeType.trade => Icons.swap_horiz,
      TradeLinkBadgeType.verification => Icons.verified,
      TradeLinkBadgeType.dispute => Icons.warning,
      TradeLinkBadgeType.success => Icons.check_circle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.xs, vertical: TradeLinkSpacing.base),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(TradeLinkRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 14, color: _fgColor()),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _fgColor()),
          ),
        ],
      ),
    );
  }
}
