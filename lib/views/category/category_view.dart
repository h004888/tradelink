import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_text.dart';

class CategoryView extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryView({super.key, required this.categoryId, this.categoryName = ''});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel(categoryId: categoryId, categoryName: categoryName)..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: vm.categoryName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.card(),
        Error(message: final m) => Center(
            child: EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được danh mục',
              message: m,
              actionLabel: 'Thử lại',
              onAction: vm.load,
            ),
          ),
        Success(data: final items) => items.isEmpty
            ? Center(
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Danh mục này chưa có tin đăng',
                  message: 'Hãy quay lại sau hoặc thử danh mục khác.',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, i) => _buildItemCard(context, items[i], vm, theme),
              ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildItemCard(BuildContext context, Listing item, CategoryViewModel vm, ThemeData theme) {
    final hasImages = item.imageUrls.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => vm.goToItemDetail(context, item.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TradeLinkColors.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              // ── Ảnh sản phẩm ──
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64, height: 64,
                  color: TradeLinkColors.surfaceContainerHigh,
                  child: hasImages
                      ? Image.network(
                          item.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            color: TradeLinkColors.outlineVariant,
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          color: TradeLinkColors.outlineVariant,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TradeLinkText.money(item.priceFormatted, size: 'compact'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
