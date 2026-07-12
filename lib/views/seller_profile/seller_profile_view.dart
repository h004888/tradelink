import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/seller_profile_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/seller_profile_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/tradelink_app_bar.dart';

class SellerProfileView extends StatelessWidget {
  final String userId;
  const SellerProfileView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerProfileViewModel(userId: userId)..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SellerProfileViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Người bán',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.profile(),
        Error(message: final m) => Center(
            child: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Không tải được thông tin',
              message: m,
              actionLabel: 'Thử lại',
              onAction: vm.load,
            ),
          ),
        Success(data: final profile) => _buildProfile(context, profile, theme, vm),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildProfile(BuildContext context, PublicSellerProfile profile, ThemeData theme, SellerProfileViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + Name ──
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.verified, size: 20, color: TradeLinkColors.tradeTeal),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tham gia ${_formatDate(profile.memberSince)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Trust Stats ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TradeLinkColors.cardBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                _StatItem(label: 'GD thành công', value: '${profile.completedTransactions}'),
                _StatDivider(),
                _StatItem(label: 'Tỷ lệ HT', value: '${profile.successRate.toStringAsFixed(0)}%'),
                _StatDivider(),
                _StatItem(label: 'Đánh giá', value: '${profile.rating.toStringAsFixed(1)}'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Trust Badges ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.responseTime != null)
                _TrustBadge(
                  icon: Icons.timer_outlined,
                  label: 'Phản hồi: ${profile.responseTime}',
                ),
              if (profile.shipOnTimeRate != null)
                _TrustBadge(
                  icon: Icons.local_shipping_outlined,
                  label: 'Giao đúng hẹn: ${profile.shipOnTimeRate!.toStringAsFixed(0)}%',
                ),
              _TrustBadge(
                icon: Icons.inventory_2_outlined,
                label: '${profile.activeListings} tin đang bán',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Active listings ──
          Text(
            'Tin đang bán',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (profile.listings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Người bán chưa có tin đăng nào.',
                textAlign: TextAlign.center,
                style: TextStyle(color: TradeLinkColors.onSurfaceVariant),
              ),
            )
          else
            ...profile.listings.map((listing) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: listing.imageUrl != null
                        ? Image.network(
                            listing.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: TradeLinkColors.surfaceContainerHigh,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined,
                                  color: TradeLinkColors.outlineVariant, size: 28),
                            ),
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : Container(
                              color: TradeLinkColors.surfaceContainerHigh,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : Container(
                            color: TradeLinkColors.surfaceContainerHigh,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_outlined,
                                color: TradeLinkColors.outlineVariant, size: 28),
                          ),
                  ),
                ),
                title: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(listing.priceFormatted, style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => vm.goToItemDetail(context, listing.id),
              ),
            )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: TradeLinkColors.cardBorder.withValues(alpha: 0.5),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TradeLinkColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: TradeLinkColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
