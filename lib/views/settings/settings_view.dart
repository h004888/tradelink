import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Cài đặt'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section(
              context,
              title: 'Tài khoản',
              children: [
                _tile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () => context.push(AppPaths.changePassword),
                ),
                _tile(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Chỉnh sửa hồ sơ',
                  onTap: () => context.push(AppPaths.editProfile),
                ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            _section(
              context,
              title: 'Thông báo',
              children: const [
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo giao dịch',
                  value: true,
                ),
                _SwitchTile(
                  icon: Icons.chat_outlined,
                  title: 'Thông báo tin nhắn',
                  value: true,
                ),
                _SwitchTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Thông báo đề nghị',
                  value: true,
                ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            _section(
              context,
              title: 'Ngôn ngữ',
              children: [
                _tile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  trailing: Text(
                    'Tiếng Việt',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: TradeLinkColors.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _showLangSheet(context),
                ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            // Logout — destructive
            TradeLinkButton.cta(
              label: 'Đăng xuất',
              icon: Icons.logout,
              isLoading: vm.logoutState is Loading,
              onPressed: vm.logoutState is Loading
                  ? null
                  : () async {
                      final ok = await vm.logout();
                      if (ok && context.mounted) context.go(AppPaths.login);
                    },
            ),
            if (vm.logoutState is Error) ...[
              const SizedBox(height: TradeLinkSpacing.sm),
              Text(
                (vm.logoutState as Error).message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: TradeLinkColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: TradeLinkSpacing.lg),
            Center(
              child: Text(
                'TradeLink v${AppConstants.appVersion}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: TradeLinkColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: TradeLinkSpacing.xs, bottom: TradeLinkSpacing.xs),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: TradeLinkColors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        TradeLinkCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: TradeLinkColors.cardDivider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: TradeLinkColors.onSurfaceVariant),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLangSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TradeLinkRadii.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _LangTile(value: 'vi', label: 'Tiếng Việt'),
              _LangTile(value: 'en', label: 'English'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: TradeLinkColors.onSurfaceVariant),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      value: value,
      onChanged: null,
    );
  }
}

class _LangTile extends StatelessWidget {
  final String value;
  final String label;
  const _LangTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: 'vi',
      onChanged: null,
      title: Text(label),
    );
  }
}