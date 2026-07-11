import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/search_results_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/tradelink_text.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchResultsViewModel(),
      child: const _Body(),
    );
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchResultsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: '',
        showBottomBorder: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TradeLinkSpacing.md, 0,
              TradeLinkSpacing.md, TradeLinkSpacing.md,
            ),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.md),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                border: Border.all(color: TradeLinkColors.inputBorder, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: TradeLinkColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: TradeLinkSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm, danh mục...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: vm.onQueryChanged,
                      onSubmitted: (value) => vm.submitQuery(value),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        vm.clearSearch();
                      },
                      color: TradeLinkColors.onSurfaceVariant,
                    ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {},
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: vm.showSuggestions && _controller.text.isEmpty
                ? _SuggestionsPanel(vm: vm, controller: _controller)
                : switch (vm.state) {
                    Idle() => _SuggestionsPanel(vm: vm, controller: _controller),
                    Loading() => const LoadingSkeleton.list(itemCount: 6),
                    Error(message: final m) => EmptyState(
                        icon: Icons.search_off_outlined,
                        title: 'Có lỗi xảy ra',
                        message: m,
                        actionLabel: 'Thử lại',
                        onAction: () => vm.search(_controller.text),
                      ),
                    Success(data: final items) => items.isEmpty
                        ? _buildEmptySearch(vm)
                        : ListView.builder(
                            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                            itemCount: items.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
                              child: _ResultCard(
                                item: items[i],
                                onTap: () => vm.goToItem(context, items[i].id),
                              ),
                            ),
                          ),
                    _ => const SizedBox.shrink(),
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(SearchResultsViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 64,
              color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả cho "${vm.query}"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử các gợi ý sau:',
            style: TextStyle(color: TradeLinkColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _SuggestionChip(label: 'Mở rộng khoảng giá', onTap: () {}),
          const SizedBox(height: 8),
          _SuggestionChip(label: 'Tăng bán kính tìm kiếm', onTap: () {}),
          const SizedBox(height: 8),
          _SuggestionChip(label: 'Xóa bộ lọc hiện tại', onTap: () {}),
          const SizedBox(height: 8),
          _SuggestionChip(label: 'Lưu tìm kiếm để nhận thông báo', onTap: () {}),
        ],
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  final SearchResultsViewModel vm;
  final TextEditingController controller;
  const _SuggestionsPanel({required this.vm, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        // Recent searches
        if (vm.recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.history, size: 16, color: TradeLinkColors.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('Tìm kiếm gần đây',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ...vm.recentSearches.map((s) => ListTile(
            dense: true,
            leading: Icon(Icons.access_time, size: 16,
                color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.5)),
            title: Text(s),
            trailing: IconButton(
              icon: Icon(Icons.close, size: 16,
                  color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.5)),
              onPressed: () => vm.removeRecentSearch(s),
            ),
            onTap: () => vm.selectSuggestion(s),
          )),
          const Divider(),
        ],

        // Popular searches
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: TradeLinkColors.onSurfaceVariant),
              const SizedBox(width: 8),
              const Text('Tìm kiếm phổ biến',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vm.popularSearches.map((s) => ActionChip(
            label: Text(s, style: const TextStyle(fontSize: 13)),
            onPressed: () {
              controller.text = s;
              vm.selectSuggestion(s);
            },
          )).toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      avatar: const Icon(Icons.lightbulb_outline, size: 16),
      onPressed: onTap,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: TradeLinkColors.primaryContainer,
      labelStyle: TextStyle(color: selected ? Colors.white : TradeLinkColors.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TradeLinkRadii.full)),
      side: BorderSide.none,
      showCheckmark: false,
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Listing item;
  final VoidCallback onTap;
  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TradeLinkCard(
      onTap: onTap,
      padding: const EdgeInsets.all(TradeLinkSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, size: 32, color: TradeLinkColors.outlineVariant),
          ),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: TradeLinkSpacing.xs),
                TradeLinkText.money(item.priceFormatted, size: 'compact'),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: TradeLinkColors.onSurfaceVariant),
        ],
      ),
    );
  }
}
