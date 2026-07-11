import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/change_password_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
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
      duration: const Duration(milliseconds: 400),
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
    final vm = context.watch<ChangePasswordViewModel>();
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
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
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
                      'Đổi mật khẩu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TradeLinkSpacing.xxl),

                // Info card
                Container(
                  padding: const EdgeInsets.all(TradeLinkSpacing.md),
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
                    border: Border.all(
                      color: TradeLinkColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: TradeLinkColors.actionBlue
                              .withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: TradeLinkColors.actionBlue,
                        ),
                      ),
                      const SizedBox(width: TradeLinkSpacing.sm),
                      Expanded(
                        child: Text(
                          'Vui lòng nhập mật khẩu cũ và mật khẩu mới để thay đổi.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TradeLinkColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.xl),

                // Fields
                _SecureField(
                  label: 'Mật khẩu cũ',
                  hint: 'Nhập mật khẩu hiện tại',
                  onChanged: vm.setOld,
                ),
                const SizedBox(height: TradeLinkSpacing.md),
                _SecureField(
                  label: 'Mật khẩu mới',
                  hint: 'Tối thiểu 6 ký tự',
                  onChanged: vm.setNew,
                ),
                const SizedBox(height: TradeLinkSpacing.md),
                _SecureField(
                  label: 'Xác nhận mật khẩu mới',
                  hint: 'Nhập lại mật khẩu mới',
                  onChanged: vm.setConfirm,
                ),

                if (vm.state is Error) ...[
                  const SizedBox(height: TradeLinkSpacing.sm),
                  Text(
                    (vm.state as Error).message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TradeLinkColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: TradeLinkSpacing.xl),
                TradeLinkButton.cta(
                  label: 'Xác nhận đổi',
                  isLoading: vm.state is Loading,
                  onPressed: vm.state is Loading
                      ? null
                      : () async {
                          final ok = await vm.submit();
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đổi mật khẩu thành công'),
                              ),
                            );
                            context.pop();
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecureField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SecureField({
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
