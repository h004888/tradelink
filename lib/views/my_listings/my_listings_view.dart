import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/my_listings_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class MyListingsView extends StatelessWidget {
  const MyListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyListingsViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyListingsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Tin đăng của tôi',
        subtitle: 'Quản lý tin bán và trao đổi',
        actions: [
          IconButton(
<<<<<<< HEAD
            icon: const Icon(Icons.drafts_outlined),
            tooltip: 'Nháp tin đăng',
=======
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'Đề nghị nhận được',
            onPressed: () => context.push('${AppPaths.offersList}?scope=received'),
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Tin nháp',
>>>>>>> main
            onPressed: () => context.push(AppPaths.draftListings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.md,
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.sm,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Đang hiển thị',
                  selected: vm.filter == ListingStatus.active,
                  onTap: () => vm.setFilter(ListingStatus.active),
                ),
                const SizedBox(width: TradeLinkSpacing.xs),
                _FilterChip(
                  label: 'Đã bán',
                  selected: vm.filter == ListingStatus.sold,
                  onTap: () => vm.setFilter(ListingStatus.sold),
                ),
                const SizedBox(width: TradeLinkSpacing.xs),
                _FilterChip(
                  label: 'Đã ẩn',
                  selected: vm.filter == ListingStatus.hidden,
                  onTap: () => vm.setFilter(ListingStatus.hidden),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (vm.state) {
              Loading() => const LoadingSkeleton.list(itemCount: 5),
              Error(message: final m) => EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Không tải được tin đăng',
                  message: m,
                  actionLabel: 'Thử lại',
                  onAction: vm.loadListings,
                ),
              Success(data: final listings) => listings.isEmpty
                  ? ListingEmptyState(onCreate: () => context.push(AppPaths.createListing))
                  : RefreshIndicator(
                      onRefresh: vm.loadListings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                        itemCount: listings.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
                          child: _ListingCard(listing: listings[i]),
                        ),
                      ),
                    ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
      floatingActionButton: vm.state is Success && (vm.state as Success<List<Listing>>).data.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppPaths.createListing),
              backgroundColor: TradeLinkColors.primaryContainer,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Đăng tin mới'),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.md,
          vertical: TradeLinkSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? TradeLinkColors.primaryContainer
              : TradeLinkColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(TradeLinkRadii.full),
          border: Border.all(
            color: selected
                ? TradeLinkColors.primaryContainer
                : TradeLinkColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : TradeLinkColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return TradeLinkCard(
      onTap: () => context.push('${AppPaths.listingDetail}/${listing.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: TradeLinkSpacing.md,
        vertical: TradeLinkSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              color: TradeLinkColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TradeLinkColors.onSurface,
                      ),
                ),
                const SizedBox(height: TradeLinkSpacing.xs),
                Row(
                  children: [
                    if (listing.price != null) ...[
                      TradeLinkText.money(
                        listing.priceFormatted,
                        size: 'compact',
                      ),
                      const SizedBox(width: TradeLinkSpacing.xs),
                    ],
                    StatusBadge(
                      type: listing.type == ListingType.trade
                          ? TradeLinkBadgeType.trade
                          : TradeLinkBadgeType.escrow,
                      label: listing.type == ListingType.trade
                          ? 'Trao đổi'
                          : 'Bán',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: TradeLinkColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}