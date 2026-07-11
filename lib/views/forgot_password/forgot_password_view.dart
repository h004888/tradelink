import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/forgot_password_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
    final vm = context.watch<ForgotPasswordViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TradeLinkSpacing.lg),
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animCtrl,
                      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuint),
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back + title
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: TradeLinkColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                      TradeLinkRadii.lg),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 22,
                                  color: TradeLinkColors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: TradeLinkSpacing.md),
                            Text(
                              'Quên mật khẩu',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: TradeLinkSpacing.xxl),

                        // Icon hero
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: TradeLinkColors.actionBlue
                                  .withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.lock_reset,
                              size: 44,
                              color: TradeLinkColors.actionBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: TradeLinkSpacing.lg),

                        Text(
                          'Nhập email để nhận token\nđặt lại mật khẩu',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: TradeLinkColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TradeLinkSpacing.xl),

                        // Email field with label
                        _ForgotField(
                          label: 'Email',
                          hint: 'email@example.com',
                          icon: Icons.email_outlined,
                          onChanged: vm.setEmail,
                        ),
                        const SizedBox(height: TradeLinkSpacing.lg),

                        TradeLinkButton.cta(
                          label: 'Gửi token',
                          isLoading: vm.state is Loading,
                          onPressed: vm.state is Loading
                              ? null
                              : () async {
                                  final ok = await vm.submit();
                                  if (ok && context.mounted) {
                                    final token = vm.resetToken;
                                    if (token != null &&
                                        token != '<no-token>') {
                                      context.push(
                                        '${AppPaths.resetPassword}?token=$token',
                                      );
                                    }
                                  }
                                },
                        ),

                        // Success — token display
                        if (vm.state is Success<String>) ...[
                          const SizedBox(height: TradeLinkSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(TradeLinkSpacing.md),
                            decoration: BoxDecoration(
                              color: TradeLinkColors.successGreen
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                  TradeLinkRadii.lg),
                              border: Border.all(
                                color: TradeLinkColors.successGreen
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: TradeLinkColors.successGreen,
                                    ),
                                    const SizedBox(
                                        width: TradeLinkSpacing.xs),
                                    Text(
                                      'Token đã được tạo',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: TradeLinkColors.successGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: TradeLinkSpacing.sm),
                                Text(
                                  '(Do chưa có email service, token hiển thị ở đây:)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: TradeLinkColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: TradeLinkSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SelectableText(
                                        vm.resetToken ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              TradeLinkColors.successGreen,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 20,
                                        color: TradeLinkColors.successGreen,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: vm.resetToken ?? ''));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Đã copy token'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (vm.state is Error) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Text(
                            (vm.state as Error).message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: TradeLinkColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ForgotField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _ForgotField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
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
          keyboardType: TextInputType.emailAddress,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
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
