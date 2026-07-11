import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/tradelink_button.dart';

class VerifyPromptView extends StatefulWidget {
  final String email;
  const VerifyPromptView({super.key, required this.email});

  @override
  State<VerifyPromptView> createState() => _VerifyPromptViewState();
}

class _VerifyPromptViewState extends State<VerifyPromptView>
    with SingleTickerProviderStateMixin {
  UiState<void> _state = const Idle();
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    setState(() => _state = const Loading());
    final repo = AuthRepository();
    final res = await repo.forgotPassword(widget.email);
    if (!mounted) return;
    setState(() {
      _state = res.isSuccess
          ? const Success(null)
          : Error(message: (res as FailureResult<String>).failure.message, retryable: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.lg),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Mail icon ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TradeLinkRadii.xl + 4),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 52,
                    color: TradeLinkColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.xl),

                // ── Title ──
                Text(
                  'Xác nhận email của bạn',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01 * 24,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TradeLinkSpacing.md),

                // ── Description ──
                Text(
                  'Chúng tôi đã gửi email xác nhận đến\n${widget.email}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                Container(
                  padding: const EdgeInsets.all(TradeLinkSpacing.md),
                  decoration: BoxDecoration(
                    color: TradeLinkColors.tradeTeal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
                    border: Border.all(
                      color: TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: TradeLinkColors.tradeTeal),
                      const SizedBox(width: TradeLinkSpacing.sm),
                      Expanded(
                        child: Text(
                          'Vui lòng kiểm tra hộp thư (và thư mục Spam) và nhấn vào link xác nhận.',
                          style: TextStyle(
                            fontSize: 13,
                            color: TradeLinkColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: TradeLinkSpacing.xl),

                // ── CTA: Tôi đã xác nhận ──
                TradeLinkButton.cta(
                  label: 'Đã xác nhận, vào TradeLink',
                  icon: Icons.arrow_forward,
                  onPressed: () => context.go(AppPaths.home),
                ),
                const SizedBox(height: TradeLinkSpacing.md),

                // ── Resend ──
                switch (_state) {
                  Loading() => const Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Error(message: final m) => Column(
                      children: [
                        Text(m, style: const TextStyle(color: TradeLinkColors.error, fontSize: 13)),
                        const SizedBox(height: TradeLinkSpacing.sm),
                        TextButton(
                          onPressed: _resendVerification,
                          child: const Text('Gửi lại email xác nhận'),
                        ),
                      ],
                    ),
                  _ => TextButton(
                      onPressed: _resendVerification,
                      child: const Text('Gửi lại email xác nhận'),
                    ),
                },

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
