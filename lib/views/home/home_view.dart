import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => HomeViewModel(), child: const _HomeBody());
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: const Text('TradeLink', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push(AppPaths.notifications)),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push(AppPaths.profile)),
        ],
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
          child: GestureDetector(
            onTap: () => vm.goToSearch(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.lg)),
              child: const Row(children: [Icon(Icons.search, color: TradeLinkColors.onSurfaceVariant), SizedBox(width: 8), Text('Tìm kiếm...', style: TextStyle(color: TradeLinkColors.onSurfaceVariant))]),
            ),
          ),
        ),
        // Category chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.marginMobile),
            itemCount: HomeViewModel.categories.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(HomeViewModel.categories[i]),
                selected: vm.selectedCategory == i,
                onSelected: (_) => vm.selectCategory(i),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Featured listings
        Expanded(
          child: switch (vm.featured) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Error(message: final m) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(m), const SizedBox(height: 12), ElevatedButton(onPressed: vm.load, child: const Text('Thử lại')),
            ])),
            Success(data: final items) => GridView.builder(
                padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                itemCount: items.length,
                itemBuilder: (_, i) => _ItemCard(item: items[i], onTap: () => vm.goToItemDetail(context, items[i].id)),
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Listing item;
  final VoidCallback onTap;
  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Container(decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: const BorderRadius.vertical(top: Radius.circular(TradeLinkRadii.lg))), child: const Center(child: Icon(Icons.image, size: 48, color: TradeLinkColors.onSurfaceVariant))),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(item.priceFormatted, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue)),
            ]),
          ),
        ]),
      ),
    );
  }
}
