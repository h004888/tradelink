import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => vm.navigateToSettings(context)),
        ],
      ),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final msg) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg, style: const TextStyle(color: TradeLinkColors.error)),
                const SizedBox(height: TradeLinkSpacing.md),
                ElevatedButton(onPressed: vm.loadProfile, child: const Text('Thử lại')),
              ],
            ),
          ),
        Success(data: final profile) => _buildProfile(context, vm, profile),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildProfile(BuildContext context, ProfileViewModel vm, Profile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        children: [
          // Avatar + Name
          const SizedBox(height: TradeLinkSpacing.lg),
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.surfaceContainerHigh,
              border: Border.all(color: _reputationColor(profile.reputationScore), width: 3),
            ),
            child: const Icon(Icons.person, size: 48, color: TradeLinkColors.onSurfaceVariant),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: TradeLinkColors.onSurface)),
          Text(profile.address ?? '', style: const TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant)),
          const SizedBox(height: TradeLinkSpacing.md),
          // Reputation Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.sm, vertical: TradeLinkSpacing.base),
            decoration: BoxDecoration(
              color: _reputationColor(profile.reputationScore).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16, color: _reputationColor(profile.reputationScore)),
                const SizedBox(width: 4),
                Text('${profile.reputationScore} điểm • Hạng ${profile.reputationTier}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _reputationColor(profile.reputationScore))),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('${profile.totalTransactions}', 'Giao dịch'),
              _statItem('${profile.successRate}%', 'Thành công'),
              _statItem('${profile.totalListings}', 'Tin đăng'),
            ],
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Menu items
          _menuItem(Icons.list_alt, 'Tin đăng của tôi', () => vm.navigateToMyListings(context)),
          _menuItem(Icons.edit, 'Chỉnh sửa hồ sơ', () => vm.navigateToEditProfile(context)),
          _menuItem(Icons.notifications_outlined, 'Thông báo', () {}),
          const Divider(height: TradeLinkSpacing.xl),
          _menuItem(Icons.logout, 'Đăng xuất', () => vm.logout(context), isDestructive: true),
        ],
      ),
    );
  }

  Color _reputationColor(int score) {
    if (score >= 90) return const Color(0xFFF59E0B); // Gold
    if (score >= 70) return const Color(0xFF94A3B8); // Silver
    if (score >= 50) return const Color(0xFFD97706); // Bronze
    return TradeLinkColors.onSurfaceVariant;
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: TradeLinkColors.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? TradeLinkColors.error : TradeLinkColors.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: isDestructive ? TradeLinkColors.error : TradeLinkColors.onSurface, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: TradeLinkColors.onSurfaceVariant),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
