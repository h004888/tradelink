import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/otp_verification_viewmodel.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpVerificationViewModel(),
      child: const _OtpBody(),
    );
  }
}

class _OtpBody extends StatelessWidget {
  const _OtpBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtpVerificationViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TradeLinkSpacing.xxl),
              // Logo
              const Center(child: Icon(Icons.shield, size: 48, color: TradeLinkColors.primaryContainer)),
              const SizedBox(height: TradeLinkSpacing.lg),
              const Text('Xác thực tài khoản', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: TradeLinkColors.onSurface), textAlign: TextAlign.center),
              const SizedBox(height: TradeLinkSpacing.xs),
              const Text('Chúng tôi đã gửi mã xác thực đến số điện thoại của bạn', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: TradeLinkSpacing.xl),
              // OTP input — 6 boxes
              _OtpInput(onChanged: vm.onOtpChanged, onComplete: vm.verify),
              const SizedBox(height: TradeLinkSpacing.lg),
              if (vm.state is Error) ...[
                Text((vm.state as Error).message, style: const TextStyle(color: TradeLinkColors.error, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: TradeLinkSpacing.md),
              ],
              // Timer + Resend
              Center(
                child: vm.canResend
                    ? TextButton(onPressed: vm.resend, child: const Text('Gửi lại mã'))
                    : Text('Gửi lại mã sau 00:${vm.secondsRemaining.toString().padLeft(2, '0')}', style: const TextStyle(color: TradeLinkColors.onSurfaceVariant, fontSize: 14)),
              ),
              const SizedBox(height: TradeLinkSpacing.lg),
              // Verify button
              ElevatedButton(
                onPressed: (vm.otp.length == 6 && vm.state is! Loading) ? vm.verify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeLinkColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
                ),
                child: vm.state is Loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Xác thực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              // Trust badge
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, size: 14, color: TradeLinkColors.onSurfaceVariant),
                    SizedBox(width: 4),
                    Text('Bảo mật bởi TradeLink', style: TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: TradeLinkSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpInput extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  _OtpInput({required this.onChanged, required this.onComplete});

  String get _value => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(TradeLinkRadii.base), borderSide: const BorderSide(color: TradeLinkColors.inputBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TradeLinkRadii.base), borderSide: const BorderSide(color: TradeLinkColors.actionBlue, width: 2)),
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            onChanged: (v) {
              if (v.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              onChanged(_value);
              if (_value.length == 6) onComplete();
            },
          ),
        );
      }),
    );
  }
}
