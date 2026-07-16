import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/search_results_viewmodel.dart';

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
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchResultsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──
            _buildSearchBar(vm),

            // ── Content ──
            Expanded(
              child: vm.showSuggestions && _controller.text.isEmpty
                  ? _buildInitialPanel(vm)
                  : vm.showSuggestions && _controller.text.isNotEmpty
                      ? _buildAutocompletePanel(vm)
                      : _buildResultsPanel(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchResultsViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TradeLinkColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: TradeLinkColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: vm.onQueryChanged,
                      onSubmitted: vm.submitQuery,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        vm.clearSearch();
                        _focusNode.requestFocus();
                      },
                      color: TradeLinkColors.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Initial panel (popular + recent) ──
  Widget _buildInitialPanel(SearchResultsViewModel vm) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Popular searches
        _buildSectionHeader('🔥 Tìm kiếm phổ biến'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vm.popularSearches.map((s) => ActionChip(
            label: Text(s, style: const TextStyle(fontSize: 13)),
            onPressed: () {
              _controller.text = s;
              vm.submitQuery(s);
            },
          )).toList(),
        ),

        // Recent searches
        if (vm.recentSearches.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('🕐 Lịch sử tìm kiếm'),
          const SizedBox(height: 8),
          ...vm.recentSearches.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time, size: 18, color: TradeLinkColors.onSurfaceVariant),
            title: Text(s, style: const TextStyle(fontSize: 14)),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => vm.removeRecentSearch(s),
              color: TradeLinkColors.onSurfaceVariant,
            ),
            onTap: () {
              _controller.text = s;
              vm.submitQuery(s);
            },
          )),
          Center(
            child: TextButton(
              onPressed: vm.clearAllRecentSearches,
              child: const Text('Xóa tất cả', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ],
    );
  }

  // ── Autocomplete panel ──
  Widget _buildAutocompletePanel(SearchResultsViewModel vm) {
    if (vm.suggestions == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final hasCategories = vm.suggestions!.categories.isNotEmpty;
    final hasProducts = vm.suggestions!.products.isNotEmpty;

    if (!hasCategories && !hasProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48,
              color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Không tìm thấy gợi ý cho "${vm.query}"',
              style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Category suggestions
        if (hasCategories) ...[
          _buildSectionHeader('📂 Danh mục'),
          const SizedBox(height: 4),
          ...vm.suggestions!.categories.map((c) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.folder_outlined, size: 20, color: TradeLinkColors.onSurfaceVariant),
            ),
            title: Text(c.name, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              _controller.text = c.name;
              vm.submitQuery(c.name);
            },
          )),
        ],

        // Product suggestions
        if (hasProducts) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('🛍️ Sản phẩm liên quan'),
          const SizedBox(height: 4),
          ...vm.suggestions!.products.map((p) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48, height: 48,
                color: TradeLinkColors.surfaceContainerHigh,
                child: p.imageUrl.isNotEmpty
                    ? Image.network(p.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.image_outlined,
                          color: TradeLinkColors.outlineVariant))
                    : const Icon(Icons.image_outlined, color: TradeLinkColors.outlineVariant),
              ),
            ),
            title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14)),
            subtitle: p.price != null
                ? TradeLinkText.money(formatVnd(p.price!), size: 'compact')
                : null,
            onTap: () => vm.goToItem(context, p.id),
          )),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Results panel ──
  Widget _buildResultsPanel(SearchResultsViewModel vm) {
    return switch (vm.state) {
      Loading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      Error(message: final m) => _buildError(m, vm),
      Success(data: final items) => items.isEmpty
          ? _buildEmpty(vm)
          : _buildResultsList(vm, items),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildResultsList(SearchResultsViewModel vm, List<Listing> items) {
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(vm),
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tìm thấy ${items.length} kết quả cho "${vm.query}"',
              style: TextStyle(color: TradeLinkColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (_, i) => _ResultCard(
              item: items[i],
              onTap: () => vm.goToItem(context, items[i].id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(SearchResultsViewModel vm) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            selected: vm.typeFilter == null,
            onTap: () => vm.setTypeFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Bán',
            selected: vm.typeFilter == ListingType.sale,
            onTap: () => vm.setTypeFilter(ListingType.sale),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Trao đổi',
            selected: vm.typeFilter == ListingType.trade,
            onTap: () => vm.setTypeFilter(ListingType.trade),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, SearchResultsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48,
              color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.search(vm.query),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(SearchResultsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64,
              color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả cho "${vm.query}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử từ khóa khác hoặc xem danh mục',
              style: TextStyle(color: TradeLinkColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
  }
}

// ── Filter Chip ──
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
          color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : TradeLinkColors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Result Card ──
class _ResultCard extends StatelessWidget {
  final Listing item;
  final VoidCallback onTap;

  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TradeLinkColors.cardBorder),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72, height: 72,
                  color: TradeLinkColors.surfaceContainerHigh,
                  child: item.imageUrls.isNotEmpty
                      ? Image.network(item.imageUrls.first, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.image_outlined,
                            color: TradeLinkColors.outlineVariant, size: 32))
                      : const Icon(Icons.image_outlined,
                          color: TradeLinkColors.outlineVariant, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3)),
                    const SizedBox(height: 4),
                    TradeLinkText.money(item.priceFormatted, size: 'compact'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12,
                          color: TradeLinkColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(item.category,
                          style: TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: TradeLinkColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
