import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme.dart';

/// Banner giao dịch an toàn — xanh ngọc + illustration khiên + CTA
class SafeTransactionBanner extends StatelessWidget {
  const SafeTransactionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () => context.push('/trust-and-safety'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TradeLinkColors.trustTeal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TradeLinkColors.trustTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Giao dịch an toàn',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: TradeLinkColors.trustTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mua bán an toàn với\nbảo vệ Escrow',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TradeLinkColors.trustTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tìm hiểu ngay',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: TradeLinkColors.trustTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.shield_rounded, size: 28, color: TradeLinkColors.trustTeal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
