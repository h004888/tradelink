import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/search_results_viewmodel.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => SearchResultsViewModel(), child: const _Body());
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchResultsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tìm kiếm...', border: InputBorder.none),
          onSubmitted: vm.search,
        ),
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () {})],
      ),
      body: Column(children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.marginMobile, vertical: 8),
          child: Row(children: [
            _Chip(label: 'Tất cả', selected: vm.state is Idle, onTap: () => vm.setTypeFilter(null)),
            _Chip(label: 'Bán', selected: false, onTap: () => vm.setTypeFilter(ListingType.sale)),
            _Chip(label: 'Trao đổi', selected: false, onTap: () => vm.setTypeFilter(ListingType.trade)),
          ]),
        ),
        Expanded(
          child: switch (vm.state) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Error(message: final m) => Center(child: Text(m)),
            Success(data: final items) => items.isEmpty
                ? const Center(child: Text('Không tìm thấy kết quả', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)))
                : ListView.builder(
                    padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _ResultCard(item: items[i], onTap: () => vm.goToItem(context, items[i].id)),
                  ),
            _ => const Center(child: Text('Nhập từ khóa để tìm kiếm', style: TextStyle(color: TradeLinkColors.onSurfaceVariant))),
          },
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
  );
}

class _ResultCard extends StatelessWidget {
  final Listing item; final VoidCallback onTap;
  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Container(width: 64, height: 64, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Icon(Icons.image)),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.priceFormatted, style: const TextStyle(fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue)),
      onTap: onTap,
    ),
  );
}
