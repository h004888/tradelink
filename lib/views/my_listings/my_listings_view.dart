import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/my_listings_viewmodel.dart';
import '../../widgets/status_badge.dart';

class MyListingsView extends StatelessWidget {
  const MyListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => MyListingsViewModel(), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyListingsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Tin đăng của tôi')),
      body: Column(children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.marginMobile, vertical: TradeLinkSpacing.xs),
          child: Row(children: [
            _FilterChip(label: 'Đang hiển thị', selected: vm.filter == ListingStatus.active, onTap: () => vm.setFilter(ListingStatus.active)),
            const SizedBox(width: 8),
            _FilterChip(label: 'Đã bán', selected: vm.filter == ListingStatus.sold, onTap: () => vm.setFilter(ListingStatus.sold)),
            const SizedBox(width: 8),
            _FilterChip(label: 'Đã ẩn', selected: vm.filter == ListingStatus.hidden, onTap: () => vm.setFilter(ListingStatus.hidden)),
          ]),
        ),
        // List
        Expanded(
          child: switch (vm.state) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Error(message: final m) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(m, style: const TextStyle(color: TradeLinkColors.error)),
              const SizedBox(height: 12), ElevatedButton(onPressed: vm.loadListings, child: const Text('Thử lại')),
            ])),
            Success(data: final listings) => listings.isEmpty
                ? const Center(child: Text('Chưa có tin đăng nào', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)))
                : ListView.builder(
                    padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                    itemCount: listings.length,
                    itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
                  ),
            _ => const SizedBox.shrink(),
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppPaths.createListing),
        icon: const Icon(Icons.add),
        label: const Text('Đăng tin mới'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(TradeLinkRadii.full),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : TradeLinkColors.onSurfaceVariant)),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
      child: ListTile(
        leading: Container(width: 56, height: 56, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Icon(Icons.image, color: TradeLinkColors.onSurfaceVariant)),
        title: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(children: [
          if (listing.price != null) Text(listing.priceFormatted, style: const TextStyle(fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue, fontSize: 13)),
          const SizedBox(width: 8),
          StatusBadge(type: listing.type == ListingType.trade ? TradeLinkBadgeType.trade : TradeLinkBadgeType.escrow, label: listing.type == ListingType.trade ? 'Trao đổi' : 'Bán'),
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('${AppPaths.listingDetail}/${listing.id}'),
      ),
    );
  }
}
