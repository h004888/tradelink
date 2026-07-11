import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Badge thông báo — chấm đỏ + số lượng
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const NotificationBadge({
    super.key,
    this.count = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final bgColor = color ?? TradeLinkColors.disputeRed;
    final text = count > 99 ? '99+' : count.toString();

    return Positioned(
      right: 2,
      top: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
