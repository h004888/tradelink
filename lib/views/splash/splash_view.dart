import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SplashViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      body: switch (vm.state) {
        Loading() => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, size: 64, color: TradeLinkColors.primaryContainer),
                SizedBox(height: TradeLinkSpacing.lg),
                Text('TradeLink', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: TradeLinkColors.primaryContainer, letterSpacing: -0.02 * 36)),
                SizedBox(height: TradeLinkSpacing.xs),
                Text('Giao dịch an toàn, minh bạch', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant)),
              ],
            ),
          ),
        Success() => _buildReady(context, vm),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildReady(BuildContext context, SplashViewModel vm) {
    WidgetsBinding.instance.addPostFrameCallback((_) => vm.navigateNext(context));
    return const SizedBox.shrink();
  }
}
