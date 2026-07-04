import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/watchlist_viewmodel.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => WatchlistViewModel()..load(), child: const _WatchlistBody());
  }
}

class _WatchlistBody extends StatelessWidget {
  const _WatchlistBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchlistViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Tin đã lưu')),
      body: vm.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_border, size: 64, color: TradeLinkColors.outlineVariant),
              SizedBox(height: 16), Text('Danh sách trống', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: vm.items.length,
              itemBuilder: (_, i) {
                final item = vm.items[i];
                return GestureDetector(
                  onTap: () => context.push('${AppPaths.itemDetail}/${item.id}'),
                  child: Container(
                    decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Expanded(child: Container(decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: const BorderRadius.vertical(top: Radius.circular(TradeLinkRadii.lg))), child: const Center(child: Icon(Icons.image, size: 48, color: TradeLinkColors.onSurfaceVariant)))),
                      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(item.priceFormatted, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue)),
                      ])),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
