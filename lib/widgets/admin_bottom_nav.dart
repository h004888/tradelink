import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../repositories/auth_repository.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Bottom nav riêng cho khu vực quản trị — tách biệt hoàn toàn với
/// TradeLinkBottomNav của người dùng thường (Dashboard/Người dùng/Giao dịch/Đăng xuất).
class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  static const int tabDashboard = 0;
  static const int tabUsers = 1;
  static const int tabTransactions = 2;

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản quản trị?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthRepository().logout();
    await ApiClient.instance.clearTokens();
    if (context.mounted) context.go(AppPaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TradeLinkColors.surface,
        borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
        boxShadow: TradeLinkShadow.medium,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _AdminNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  selected: currentIndex == tabDashboard,
                  onTap: () {
                    if (currentIndex != tabDashboard) context.go(AppPaths.admin);
                  },
                ),
              ),
              Expanded(
                child: _AdminNavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people_rounded,
                  label: 'Người dùng',
                  selected: currentIndex == tabUsers,
                  onTap: () {
                    if (currentIndex != tabUsers) context.go(AppPaths.adminUsers);
                  },
                ),
              ),
              Expanded(
                child: _AdminNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Giao dịch',
                  selected: currentIndex == tabTransactions,
                  onTap: () {
                    if (currentIndex != tabTransactions) context.go(AppPaths.adminTransactions);
                  },
                ),
              ),
              Expanded(
                child: _AdminNavItem(
                  icon: Icons.logout,
                  activeIcon: Icons.logout,
                  label: 'Đăng xuất',
                  selected: false,
                  color: TradeLinkColors.error,
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (selected ? TradeLinkColors.primary : TradeLinkColors.onSurfaceVariant);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? activeIcon : icon, size: 22, color: c),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c),
          ),
        ],
      ),
    );
  }
}
