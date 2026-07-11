import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/reset_password_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class ResetPasswordView extends StatelessWidget {
  final String token;
  const ResetPasswordView({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(token: token),
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
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
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
    final vm = context.watch<ResetPasswordViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TradeLinkColors.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(TradeLinkRadii.lg),
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
                      'Đặt lại mật khẩu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TradeLinkSpacing.xxl),

                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: TradeLinkColors.saleBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 38,
                      color: TradeLinkColors.saleBlue,
                    ),
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                Text(
                  'Tạo mật khẩu mới',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01 * 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TradeLinkSpacing.xs),
                Text(
                  'Mật khẩu mới tối thiểu 6 ký tự',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TradeLinkSpacing.xl),

                // New password
                _Field(
                  label: 'Mật khẩu mới',
                  hint: 'Tối thiểu 6 ký tự',
                  onChanged: vm.setNew,
                ),
                const SizedBox(height: TradeLinkSpacing.md),

                // Confirm
                _Field(
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu',
                  onChanged: vm.setConfirm,
                ),
                const SizedBox(height: TradeLinkSpacing.lg),

                TradeLinkButton.cta(
                  label: 'Đặt lại mật khẩu',
                  isLoading: vm.state is Loading,
                  onPressed: vm.state is Loading
                      ? null
                      : () async {
                          final ok = await vm.submit();
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.',
                                ),
                              ),
                            );
                            context.go(AppPaths.login);
                          }
                        },
                ),

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
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.label,
    required this.hint,
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
          obscureText: true,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            filled: true,
            fillColor: TradeLinkColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TradeLinkSpacing.md,
              vertical: TradeLinkSpacing.sm + 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              borderSide: const BorderSide(
                color: TradeLinkColors.cardBorder, width: 1,
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
                color: TradeLinkColors.actionBlue, width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
