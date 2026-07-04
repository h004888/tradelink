import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/item_detail_viewmodel.dart';
import '../../widgets/status_badge.dart';

class ItemDetailView extends StatelessWidget {
  final String itemId;
  const ItemDetailView({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ItemDetailViewModel(itemId: itemId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemDetailViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(actions: [
        IconButton(icon: Icon(vm.isSaved ? Icons.bookmark : Icons.bookmark_border, color: vm.isSaved ? TradeLinkColors.primaryContainer : null), onPressed: vm.toggleSave),
      ]),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Text(m)),
        Success(data: final item) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(height: 300, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.lg)), child: const Center(child: Icon(Icons.image, size: 80, color: TradeLinkColors.onSurfaceVariant))),
              const SizedBox(height: TradeLinkSpacing.md),
              Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              if (item.price != null) ...[const SizedBox(height: 4), Text(item.priceFormatted, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue))],
              const SizedBox(height: 8),
              StatusBadge(type: item.type == ListingType.trade ? TradeLinkBadgeType.trade : TradeLinkBadgeType.escrow, label: item.type == ListingType.trade ? 'Trao đổi' : 'Bán'),
              const SizedBox(height: 12),
              Text(item.description, style: const TextStyle(fontSize: 15, color: TradeLinkColors.onSurfaceVariant, height: 1.6)),
              const SizedBox(height: 12),
              // Seller info
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: TradeLinkColors.surfaceContainerHigh), child: const Icon(Icons.person, size: 24)),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${item.category} • ${item.condition.name}', style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
                ]),
              ]),
              const SizedBox(height: 24),
              // Contact + Offer buttons
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.push('${AppPaths.chat}/conv-${item.id}'),
                  icon: const Icon(Icons.chat_outlined, size: 20), label: const Text('Liên hệ'),
                  style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => context.push('${AppPaths.sendOffer}/${item.id}'),
                  icon: const Icon(Icons.send_outlined, size: 20), label: const Text('Gửi đề nghị'),
                )),
              ]),
            ]),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
