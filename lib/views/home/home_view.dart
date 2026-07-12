import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui_state.dart';
import '../../models/filter_model.dart';
import '../../models/listing_model.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/active_transaction_card.dart';
import '../../widgets/category_horizontal_list.dart';
import '../../widgets/home_search_bar.dart';
import '../../widgets/safe_transaction_banner.dart';
import '../../widgets/tradelink_text.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMore = true;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vm = context.read<HomeViewModel>();

    // Show/hide scroll-to-top button
    setState(() {
      _showScrollToTop = _scrollController.position.pixels > 300;
    });

    // Load more
    if (_canLoadMore &&
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _canLoadMore = false;
      vm.loadMore();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _canLoadMore = true;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    Transaction? activeTx;
    if (vm.activeTransactions is Success<List<Transaction>>) {
      final txs = (vm.activeTransactions as Success<List<Transaction>>).data;
      activeTx = txs.cast<Transaction?>().firstWhere(
        (t) => t!.escrowStep != null && t.escrowStep != EscrowStep.released,
        orElse: () => null,
      );
    }

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: vm.load,
              color: TradeLinkColors.primaryContainer,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader()),
                  // Search bar
                  const SliverToBoxAdapter(child: HomeSearchBar()),
                  // Active transaction card
                  SliverToBoxAdapter(child: ActiveTransactionCard(
                    transaction: activeTx,
                    isLoading: vm.activeTransactions is Loading,
                    onTap: activeTx != null
                        ? () => vm.goToTransactionDetail(context, activeTx!)
                        : null,
                  )),
                  // Categories
                  const SliverToBoxAdapter(child: CategoryHorizontalList()),
                  // Safety banner
                  const SliverToBoxAdapter(child: SafeTransactionBanner()),
                  // Filter bar
                  SliverToBoxAdapter(child: _buildFilterBar(vm)),
                  // Active filter chips
                  if (vm.filter.hasActiveFilters)
                    SliverToBoxAdapter(child: _buildActiveFilters(vm)),
                  // ── Feed ──
                  ..._buildFeedSlivers(vm),
                ],
              ),
            ),
          ),
          // Scroll-to-top button
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 80,
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: TradeLinkColors.primaryContainer,
                mini: true,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFeedSlivers(HomeViewModel vm) {
    return switch (vm.feedState) {
      Loading() => [_buildFeedSkeleton()],
      Error(message: final m) => [_buildFeedError(m)],
      Success(data: final listings) => [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildListingCard(context, listings[index], vm),
            childCount: listings.length,
          ),
        ),
        if (vm.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        if (vm.loadMoreError != null && !vm.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Text(vm.loadMoreError!,
                      style: const TextStyle(color: TradeLinkColors.error),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: vm.retryLoadMore,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!vm.hasMore && !vm.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Đã hiển thị tất cả sản phẩm',
                  style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
              ),
            ),
          ),
      ],
      _ => [],
    };
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 32, height: 32),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push(AppPaths.notifications),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(HomeViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter button
          ActionChip(
            avatar: Icon(Icons.filter_list,
              size: 18,
              color: vm.filter.hasActiveFilters
                  ? TradeLinkColors.primaryContainer
                  : TradeLinkColors.onSurfaceVariant),
            label: Text('Lọc',
              style: TextStyle(
                color: vm.filter.hasActiveFilters
                    ? TradeLinkColors.primaryContainer
                    : TradeLinkColors.onSurfaceVariant)),
            onPressed: () => _showFilterSheet(vm),
          ),
          const SizedBox(width: 8),
          // Price sort
          ActionChip(
            avatar: Icon(
              vm.filter.sort == 'price_asc' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: TradeLinkColors.onSurfaceVariant),
            label: Text('Giá',
              style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
            onPressed: () {
              final newSort = vm.filter.sort == 'price_asc' ? 'price_desc' : 'price_asc';
              vm.updateFilter(vm.filter.copyWith(sort: newSort));
            },
          ),
          const SizedBox(width: 8),
          // Sort dropdown
          ActionChip(
            avatar: Icon(Icons.sort,
              size: 18,
              color: TradeLinkColors.onSurfaceVariant),
            label: Text(vm.filter.sortLabel,
              style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
            onPressed: () => _showSortSheet(vm),
          ),
          const Spacer(),
          // Reset
          if (vm.filter.hasActiveFilters)
            TextButton(
              onPressed: vm.resetFilter,
              child: const Text('↻ Xóa'),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(HomeViewModel vm) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (vm.filter.type != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(vm.filter.type == 'sale' ? 'Bán' : 'Trao đổi',
                  style: const TextStyle(fontSize: 12)),
                onDeleted: () => vm.updateFilter(vm.filter.copyWith(type: null)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (vm.filter.maxPrice != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Dưới ${_formatPrice(vm.filter.maxPrice!)}',
                  style: const TextStyle(fontSize: 12)),
                onDeleted: () => vm.updateFilter(vm.filter.copyWith(maxPrice: null)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (vm.filter.minPrice != null && vm.filter.maxPrice != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${_formatPrice(vm.filter.minPrice!)} - ${_formatPrice(vm.filter.maxPrice!)}',
                  style: const TextStyle(fontSize: 12)),
                onDeleted: () => vm.updateFilter(vm.filter.copyWith(minPrice: null, maxPrice: null)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (vm.filter.condition != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_conditionLabel(vm.filter.condition!),
                  style: const TextStyle(fontSize: 12)),
                onDeleted: () => vm.updateFilter(vm.filter.copyWith(condition: null)),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(0)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }

  String _conditionLabel(String condition) {
    switch (condition) {
      case 'new': return 'Mới';
      case 'likeNew': return 'Như mới';
      case 'used': return 'Đã dùng';
      default: return condition;
    }
  }

  void _showFilterSheet(HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        currentFilter: vm.filter,
        onApply: (filter) {
          vm.updateFilter(filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet(HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sắp xếp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortOption(vm, 'Mới nhất', 'newest'),
            _buildSortOption(vm, 'Giá thấp đến cao', 'price_asc'),
            _buildSortOption(vm, 'Giá cao đến thấp', 'price_desc'),
            _buildSortOption(vm, 'Phổ biến nhất', 'popular'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(HomeViewModel vm, String label, String value) {
    final isSelected = vm.filter.sort == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: TradeLinkColors.primaryContainer) : null,
      onTap: () {
        vm.updateFilter(vm.filter.copyWith(sort: value));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildListingCard(BuildContext context, Listing item, HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => vm.goToItemDetail(context, item.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TradeLinkColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: item.imageUrls.isNotEmpty
                      ? Image.network(
                          item.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: TradeLinkColors.surfaceContainerHigh,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_outlined,
                              color: TradeLinkColors.outlineVariant, size: 40),
                          ),
                        )
                      : Container(
                          color: TradeLinkColors.surfaceContainerHigh,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined,
                            color: TradeLinkColors.outlineVariant, size: 40),
                        ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 6),
                    TradeLinkText.money(item.priceFormatted, size: 'compact'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12,
                          color: TradeLinkColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item.location ?? 'Chưa cập nhật',
                            style: TextStyle(fontSize: 12,
                              color: TradeLinkColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time_outlined, size: 12,
                          color: TradeLinkColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(_formatTimeAgo(item.createdAt),
                          style: TextStyle(fontSize: 12,
                            color: TradeLinkColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSkeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TradeLinkColors.cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 200,
                        decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 100,
                        decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        childCount: 5,
      ),
    );
  }

  Widget _buildFeedError(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.cloud_off_outlined, size: 48,
                color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa đăng';
  }
}

// ── Filter Bottom Sheet ──
class _FilterSheet extends StatefulWidget {
  final FeedFilter currentFilter;
  final Function(FeedFilter) onApply;

  const _FilterSheet({required this.currentFilter, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FeedFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bộ lọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _filter = const FeedFilter()),
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type filter
          _buildSection('Loại hình', [
            _buildRadio('Tất cả', _filter.type == null, (v) {
              setState(() => _filter = _filter.copyWith(type: null));
            }),
            _buildRadio('Bán qua escrow', _filter.type == 'sale', (v) {
              setState(() => _filter = _filter.copyWith(type: 'sale'));
            }),
            _buildRadio('Trao đổi', _filter.type == 'trade', (v) {
              setState(() => _filter = _filter.copyWith(type: 'trade'));
            }),
          ]),
          const SizedBox(height: 16),

          // Price filter
          _buildSection('Khoảng giá', [
            _buildRadio('Tất cả', _filter.minPrice == null && _filter.maxPrice == null, (v) {
              setState(() => _filter = _filter.copyWith(minPrice: null, maxPrice: null));
            }),
            _buildRadio('Dưới 1.000.000 đ', _filter.maxPrice == 1000000, (v) {
              setState(() => _filter = _filter.copyWith(minPrice: null, maxPrice: 1000000));
            }),
            _buildRadio('1.000.000 - 5.000.000 đ', _filter.minPrice == 1000000 && _filter.maxPrice == 5000000, (v) {
              setState(() => _filter = _filter.copyWith(minPrice: 1000000, maxPrice: 5000000));
            }),
            _buildRadio('5.000.000 - 10.000.000 đ', _filter.minPrice == 5000000 && _filter.maxPrice == 10000000, (v) {
              setState(() => _filter = _filter.copyWith(minPrice: 5000000, maxPrice: 10000000));
            }),
            _buildRadio('Trên 10.000.000 đ', _filter.minPrice == 10000000, (v) {
              setState(() => _filter = _filter.copyWith(minPrice: 10000000, maxPrice: null));
            }),
          ]),
          const SizedBox(height: 16),

          // Condition filter
          _buildSection('Tình trạng', [
            _buildRadio('Tất cả', _filter.condition == null, (v) {
              setState(() => _filter = _filter.copyWith(condition: null));
            }),
            _buildRadio('Mới', _filter.condition == 'new', (v) {
              setState(() => _filter = _filter.copyWith(condition: 'new'));
            }),
            _buildRadio('Như mới', _filter.condition == 'likeNew', (v) {
              setState(() => _filter = _filter.copyWith(condition: 'likeNew'));
            }),
            _buildRadio('Đã sử dụng', _filter.condition == 'used', (v) {
              setState(() => _filter = _filter.copyWith(condition: 'used'));
            }),
          ]),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_filter),
              style: ElevatedButton.styleFrom(
                backgroundColor: TradeLinkColors.primaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Áp dụng', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildRadio(String label, bool isSelected, Function(bool) onTap) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? TradeLinkColors.primaryContainer : TradeLinkColors.onSurfaceVariant,
        size: 20,
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () => onTap(!isSelected),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
