import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TradeLinkSpacing.xxl),
              // Logo + Title
              const Icon(Icons.shield, size: 48, color: TradeLinkColors.primaryContainer),
              const SizedBox(height: TradeLinkSpacing.md),
              const Text('TradeLink', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: TradeLinkColors.primaryContainer)),
              const SizedBox(height: TradeLinkSpacing.xs),
              const Text('Đăng nhập để tiếp tục', style: TextStyle(fontSize: 16, color: TradeLinkColors.onSurfaceVariant)),
              const SizedBox(height: TradeLinkSpacing.xxl),
              // Phone input
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                onChanged: vm.onPhoneChanged,
              ),
              if (vm.state is Error) ...[
                const SizedBox(height: TradeLinkSpacing.xs),
                Text((vm.state as Error).message, style: const TextStyle(color: TradeLinkColors.error, fontSize: 14)),
              ],
              const SizedBox(height: TradeLinkSpacing.lg),
              // Continue button
              ElevatedButton(
                onPressed: vm.state is Loading ? null : () async {
                  await vm.login();
                  if (vm.state is Success && context.mounted) {
                    vm.navigateToOtp(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeLinkColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
                ),
                child: vm.state is Loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
