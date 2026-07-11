import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Màn hình giới thiệu giao dịch an toàn (Escrow)
class TrustAndSafetyView extends StatelessWidget {
  const TrustAndSafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch an toàn'),
        backgroundColor: TradeLinkColors.surface,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 64, color: TradeLinkColors.trustTeal),
              SizedBox(height: 16),
              Text(
                'Mua bán an toàn với Escrow',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'TradeLink sử dụng cơ chế ký quỹ (Escrow) để bảo vệ '
                'cả người mua và người bán. Tiền được giữ an toàn '
                'cho đến khi cả hai bên xác nhận giao dịch thành công.',
                style: TextStyle(fontSize: 15, color: TradeLinkColors.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
