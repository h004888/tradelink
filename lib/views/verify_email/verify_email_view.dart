import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/tradelink_button.dart';

class VerifyEmailView extends StatefulWidget {
  final String token;
  const VerifyEmailView({super.key, required this.token});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView>
    with SingleTickerProviderStateMixin {
  final _repo = AuthRepository();
  UiState<void> _state = const Idle();
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    if (widget.token.isNotEmpty) _verify();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _state = const Loading());
    _animCtrl.forward();
    final res = await _repo.verifyEmail(widget.token);
    if (!mounted) return;
    setState(() {
      _state = res is ResultSuccess<bool>
          ? const Success(null)
          : Error(
              message: (res as FailureResult<bool>).failure.message,
              retryable: true,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        backgroundColor: TradeLinkColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppPaths.login),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(TradeLinkSpacing.lg),
              child: switch (_state) {
                Loading() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: TradeLinkSpacing.lg),
                      Text(
                        'Đang xác nhận email...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                Success() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconCircle(
                        icon: Icons.verified_outlined,
                        color: TradeLinkColors.successGreen,
                        bgAlpha: 0.10,
                      ),
                      const SizedBox(height: TradeLinkSpacing.lg),
                      Text(
                        'Email đã được xác nhận',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TradeLinkSpacing.xs),
                      Text(
                        'Bạn có thể đăng nhập và bắt đầu giao dịch',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TradeLinkSpacing.xl),
                      TradeLinkButton.cta(
                        label: 'Đăng nhập',
                        icon: Icons.login,
                        onPressed: () => context.go(AppPaths.login),
                      ),
                    ],
                  ),
                Error(message: final m) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconCircle(
                        icon: Icons.error_outline,
                        color: TradeLinkColors.error,
                        bgAlpha: 0.10,
                      ),
                      const SizedBox(height: TradeLinkSpacing.lg),
                      Text(
                        'Xác nhận thất bại',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: TradeLinkSpacing.xs),
                      Text(
                        m,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TradeLinkSpacing.xl),
                      TradeLinkButton.cta(
                        label: 'Thử lại',
                        onPressed: _verify,
                      ),
                    ],
                  ),
                _ => Text(
                    'Không có token xác nhận',
                    style: theme.textTheme.bodyMedium,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double bgAlpha;

  const _IconCircle({
    required this.icon,
    required this.color,
    required this.bgAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 52, color: color),
    );
  }
}
