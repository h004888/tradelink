import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterBody(),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  const _RegisterBody();
  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _headerFade;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOut),
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
    final vm = context.watch<RegisterViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TradeLinkSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: TradeLinkSpacing.lg),

                    // ── Top bar ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(
                                TradeLinkSpacing.sm - 4),
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
                      ],
                    ),

                    const SizedBox(height: TradeLinkSpacing.xl),

                    // ── Decorated brand header ──
                    FadeTransition(
                      opacity: _headerFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
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
                                  TradeLinkRadii.xl - 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A1A365D),
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: TradeLinkSpacing.md),
                          Text(
                            'Bắt đầu giao dịch\nan toàn',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.01 * 26,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Text(
                            'Tạo tài khoản miễn phí. Mọi giao dịch được bảo vệ bởi escrow.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TradeLinkSpacing.xl),

                    // ── Form ──
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animCtrl,
                          curve: const Interval(0.2, 0.8,
                              curve: Curves.easeOutQuint),
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FieldGroup(
                              label: 'Họ và tên',
                              hint: 'Nguyễn Văn A',
                              icon: Icons.person_outline,
                              onChanged: vm.onNameChanged,
                            ),
                            const SizedBox(height: TradeLinkSpacing.md),
                            _FieldGroup(
                              label: 'Email',
                              hint: 'email@example.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: vm.onEmailChanged,
                            ),
                            const SizedBox(height: TradeLinkSpacing.md),
                            _FieldGroup(
                              label: 'Mật khẩu',
                              hint: 'Tối thiểu 6 ký tự',
                              icon: Icons.lock_outline,
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

                            const SizedBox(height: TradeLinkSpacing.md),
                            _FieldGroup(
                              label: 'Xác nhận mật khẩu',
                              hint: 'Nhập lại mật khẩu',
                              icon: Icons.lock_outline,
                              obscure: vm.obscureConfirmPassword,
                              onChanged: vm.onConfirmPasswordChanged,
                              suffix: IconButton(
                                icon: Icon(
                                  vm.obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                                onPressed: vm.toggleConfirmObscure,
                              ),
                            ),

                            const SizedBox(height: TradeLinkSpacing.md),
                            _FieldGroup(
                              label: 'Số điện thoại',
                              hint: '0987654321',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              onChanged: vm.onPhoneChanged,
                            ),
                            const SizedBox(height: TradeLinkSpacing.md),
                            _FieldGroup(
                              label: 'Địa chỉ (tùy chọn)',
                              hint: '123 Đường ABC, Quận 1',
                              icon: Icons.location_on_outlined,
                              onChanged: vm.onAddressChanged,
                            ),

                            // ── Terms checkbox ──
                            const SizedBox(height: TradeLinkSpacing.sm),
                            Semantics(
                              button: true,
                              label: 'Đồng ý với Điều khoản dịch vụ',
                              checked: vm.isTermsAccepted,
                              onTap: vm.toggleTerms,
                              child: InkWell(
                                onTap: vm.toggleTerms,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: vm.isTermsAccepted
                                              ? TradeLinkColors.primaryContainer
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: vm.isTermsAccepted
                                                ? TradeLinkColors.primaryContainer
                                                : TradeLinkColors.outlineVariant,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: vm.isTermsAccepted
                                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: TradeLinkSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          'Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của TradeLink',
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
                                        style:
                                            theme.textTheme.bodySmall
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

                            TradeLinkButton.cta(
                              label: 'Tạo tài khoản',
                              isLoading: vm.state is Loading,
                              onPressed: vm.state is Loading
                                  ? null
                                  : () async {
                                      final ok = await vm.register();
                                      if (ok && context.mounted) {
                                        context.go('${AppPaths.verifyOTP}?email=${Uri.encodeComponent(vm.email)}');
                                      }
                                    },
                            ),

                            const SizedBox(height: TradeLinkSpacing.md),

                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      TradeLinkColors.primaryContainer,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Đã có tài khoản? Đăng nhập'),
                              ),
                            ),

                            const SizedBox(height: TradeLinkSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _FieldGroup({
    required this.label,
    required this.hint,
    required this.icon,
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
