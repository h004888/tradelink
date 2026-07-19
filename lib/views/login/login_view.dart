import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(redirectPath: redirect),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();
  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _brandFade;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _brandFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ═══════════════════════════════════════
                  // BRAND ZONE — chiếm ~40% màn hình
                  // ═══════════════════════════════════════
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Stack(
                      children: [
                        // Decorative blobs
                        Positioned(
                          top: -80,
                          right: -60,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TradeLinkColors.primaryContainer
                                  .withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: -40,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TradeLinkColors.actionBlue
                                  .withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TradeLinkColors.secondaryContainer
                                  .withValues(alpha: 0.06),
                            ),
                          ),
                        ),

                        // Brand content
                        Center(
                          child: FadeTransition(
                            opacity: _brandFade,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.08),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animCtrl,
                                curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuint),
                              )),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Shield — lớn hơn, bóng đậm hơn
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          TradeLinkColors.saleBlue,
                                          Color(0xFF0D2247),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          TradeLinkRadii.xl + 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x261A365D),
                                          blurRadius: 28,
                                          offset: Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: Color(0x0F1A365D),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      size: 42,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: TradeLinkSpacing.md),
                                  Text(
                                    'TradeLink',
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.02 * 30,
                                      color:
                                          TradeLinkColors.primaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Đăng nhập để tiếp tục',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: TradeLinkColors
                                          .onSurfaceVariant,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ═══════════════════════════════════════
                  // FORM ZONE — nổi lên với animation riêng
                  // ═══════════════════════════════════════
                  FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animCtrl,
                        curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuint),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TradeLinkSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email field
                            _AuthField(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              hint: 'email@example.com',
                              keyboardType: TextInputType.emailAddress,
                              onChanged: vm.onEmailChanged,
                            ),
                            const SizedBox(height: TradeLinkSpacing.md),

                            // Password field
                            _AuthField(
                              icon: Icons.lock_outline,
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu',
                              obscure: vm.obscurePassword,
                              onChanged: vm.onPasswordChanged,
                              suffix: IconButton(
                                icon: Icon(
                                  vm.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                                onPressed: vm.toggleObscure,
                              ),
                            ),

                            // Error
                            if (vm.state is Error) ...[
                              const SizedBox(height: TradeLinkSpacing.sm),
                              Container(
                                padding: const EdgeInsets.all(
                                    TradeLinkSpacing.sm),
                                decoration: BoxDecoration(
                                  color: TradeLinkColors.errorContainer
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(
                                      TradeLinkRadii.xs),
                                  border: Border.all(
                                    color: TradeLinkColors.error
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 16,
                                        color: TradeLinkColors.error),
                                    const SizedBox(
                                        width: TradeLinkSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        (vm.state as Error).message,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: TradeLinkColors.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: TradeLinkSpacing.lg),

                            // CTA
                            TradeLinkButton.cta(
                              label: 'Đăng nhập',
                              isLoading: vm.state is Loading,
                              onPressed: vm.state is Loading
                                  ? null
                                  : () async {
                                      final ok = await vm.login();
                                      if (ok && context.mounted) {
                                        // Redirect về trang trước login nếu có
                                        final redirect = vm.redirectPath;
                                        if (redirect != null &&
                                            redirect.isNotEmpty) {
                                          context.go(redirect);
                                        } else {
                                          context.go(AppPaths.home);
                                        }
                                      }
                                    },
                            ),

                            const SizedBox(height: TradeLinkSpacing.md),

                            OutlinedButton.icon(
                              onPressed: vm.state is Loading
                                  ? null
                                  : () async {
                                      final ok = await vm.loginWithGoogle();
                                      if (ok && context.mounted) {
                                        final redirect = vm.redirectPath;
                                        if (redirect != null &&
                                            redirect.isNotEmpty) {
                                          context.go(redirect);
                                        } else {
                                          context.go(AppPaths.home);
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                              label: const Text('Đăng nhập bằng Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TradeLinkColors.onSurface,
                                side: BorderSide(
                                  color: TradeLinkColors.outlineVariant
                                      .withValues(alpha: 0.7),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: TradeLinkSpacing.md,
                                  horizontal: TradeLinkSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    TradeLinkRadii.lg,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: TradeLinkSpacing.md),

                            // Bottom links
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppPaths.forgotPassword),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        TradeLinkColors.actionBlue,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Quên mật khẩu?'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppPaths.register),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        TradeLinkColors.primaryContainer,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Đăng ký'),
                                ),
                              ],
                            ),

                            const SizedBox(height: TradeLinkSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Auth Field — custom styled input
// ──────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _AuthField({
    required this.icon,
    required this.label,
    required this.hint,
    this.obscure = false,
    required this.onChanged,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: TradeLinkSpacing.base,
            bottom: TradeLinkSpacing.xs,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TradeLinkColors.onSurfaceVariant,
              letterSpacing: 0.02,
            ),
          ),
        ),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: TradeLinkColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TradeLinkSpacing.md,
              vertical: TradeLinkSpacing.sm + 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              borderSide: const BorderSide(
                color: TradeLinkColors.cardBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              borderSide: BorderSide(
                color: TradeLinkColors.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              borderSide: const BorderSide(
                color: TradeLinkColors.actionBlue,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
