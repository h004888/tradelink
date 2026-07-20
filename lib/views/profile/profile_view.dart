
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/user_reviews_section.dart';

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
      appBar: TradeLinkAppBar(
        title: 'Hồ sơ cá nhân',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => vm.navigateToSettings(context),
          ),
        ],
      ),
      body: switch (vm.state) {
        Loading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Error(message: final msg) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được hồ sơ',
            message: msg,
            actionLabel: 'Thử lại',
            onAction: vm.loadProfile,
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
          const SizedBox(height: TradeLinkSpacing.md),
          // Avatar with reputation border
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.surfaceContainerHigh,
              border: Border.all(
                color: _reputationColor(profile.reputationScore),
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? Image.network(
                      profile.avatarUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_outline,
                        size: 48,
                        color: TradeLinkColors.onSurfaceVariant,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: TradeLinkColors.onSurfaceVariant,
                    ),
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          Text(
            profile.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
          ),
          // Location card — address + coordinates
          if (profile.address?.isNotEmpty == true ||
              (profile.latitude != null && profile.longitude != null)) ...[
            const SizedBox(height: TradeLinkSpacing.md),
            TradeLinkCard(
              padding: const EdgeInsets.all(TradeLinkSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.address?.isNotEmpty == true) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: TradeLinkColors.onSurfaceVariant),
                        const SizedBox(width: TradeLinkSpacing.xs),
                        Expanded(
                          child: Text(
                            profile.address!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: TradeLinkColors.onSurface,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (profile.latitude != null && profile.longitude != null) ...[
                    if (profile.address?.isNotEmpty == true)
                      const SizedBox(height: TradeLinkSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.map_outlined,
                            size: 16, color: TradeLinkColors.onSurfaceVariant),
                        const SizedBox(width: TradeLinkSpacing.xs),
                        Text(
                          '${profile.latitude!.toStringAsFixed(4)}°N, ${profile.longitude!.toStringAsFixed(4)}°E',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: TradeLinkColors.onSurfaceVariant,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Khi chưa có địa chỉ — hint nhẹ
            const SizedBox(height: TradeLinkSpacing.sm),
            GestureDetector(
              onTap: () => vm.navigateToEditProfile(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: TradeLinkColors.actionBlue),
                  const SizedBox(width: TradeLinkSpacing.xs),
                  Text(
                    'Thêm địa chỉ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TradeLinkColors.actionBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: TradeLinkSpacing.md),
          // Reputation Badge — prominent style for trust signal
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TradeLinkSpacing.md,
              vertical: TradeLinkSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _reputationColor(profile.reputationScore).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
              border: Border.all(
                color: _reputationColor(profile.reputationScore).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: _reputationColor(profile.reputationScore),
                ),
                const SizedBox(width: TradeLinkSpacing.xs),
                Text(
                  '${profile.reputationScore} điểm • Hạng ${profile.reputationTier}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _reputationColor(profile.reputationScore),
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Stats row — TradeLinkCard
          TradeLinkCard(
            padding: const EdgeInsets.symmetric(
              horizontal: TradeLinkSpacing.md,
              vertical: TradeLinkSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(context, '${profile.totalTransactions}', 'Giao dịch'),
                Container(
                  width: 1,
                  height: 32,
                  color: TradeLinkColors.cardDivider,
                ),
                _statItem(context, '${profile.successRate}%', 'Thành công'),
                Container(
                  width: 1,
                  height: 32,
                  color: TradeLinkColors.cardDivider,
                ),
                _statItem(context, '${profile.totalListings}', 'Tin đăng'),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Menu items
          TradeLinkCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuItem(
                  context,
                  Icons.list_alt_outlined,
                  'Tin đăng của tôi',
                  onTap: () async {
                    await vm.navigateToMyListings(context);
                    vm.loadProfile();
                  },
                ),
                const Divider(height: 1, indent: 56, color: TradeLinkColors.cardDivider),
                _menuItem(
                  context,
                  Icons.drafts_outlined,
                  'Nháp tin đăng',
                  onTap: () => context.push(AppPaths.draftListings),
                ),
                const Divider(height: 1, indent: 56, color: TradeLinkColors.cardDivider),
                _menuItem(
                  context,
                  Icons.edit_outlined,
                  'Chỉnh sửa hồ sơ',
                  onTap: () async {
                    await vm.navigateToEditProfile(context);
                    vm.loadProfile();
                  },
                ),
                const Divider(height: 1, indent: 56, color: TradeLinkColors.cardDivider),
                _menuItem(
                  context,
                  Icons.bookmark_outline,
                  'Tin đã lưu',
                  onTap: () => vm.navigateToWatchlist(context),
                ),
                const Divider(height: 1, indent: 56, color: TradeLinkColors.cardDivider),
                _menuItem(
                  context,
                  Icons.notifications_outlined,
                  'Thông báo',
                  onTap: () => context.push(AppPaths.notifications),
                ),
                const Divider(height: 1, indent: 56, color: TradeLinkColors.cardDivider),
                _menuItem(
                  context,
                  Icons.logout,
                  'Đăng xuất',
                  onTap: () => vm.logout(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Public reviews section
          UserReviewsSection(userId: profile.id),
          const SizedBox(height: TradeLinkSpacing.md),
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

  Widget _statItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TradeLinkColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? TradeLinkColors.error : TradeLinkColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: TradeLinkColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}