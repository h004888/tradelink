import 'package:flutter/material.dart';

import '../core/ui_state.dart';
import '../models/listing_model.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';

/// Section sản phẩm có header + horizontal list + states.
///
/// Dùng cho cả "Nổi bật", "Mới đăng", "Phổ biến".
/// Card width và list height được tính động theo màn hình,
/// không hard-code để tránh overflow khi text scaling.
class ProductSection extends StatelessWidget {
  final String title;
  final UiState<List<Listing>> state;
  final VoidCallback? onViewAll;
  final void Function(String id) onProductTap;

  /// Chiều cao nội dung bên dưới ảnh (padding + title + gap + price).
  /// 12 (top) + 32 (title 2 dòng) + 8 (gap) + 20 (price 1 dòng) + 16 (bottom) = 88
  static const _contentHeight = 88.0;

  /// Card width tối thiểu / tối đa.
  static const _minCardWidth = 130.0;
  static const _maxCardWidth = 170.0;

  const ProductSection({
    super.key,
    required this.title,
    required this.state,
    this.onViewAll,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      Loading() => _buildLoadingState(),
      Error(message: final m, retryable: true) => _buildErrorState(m),
      Success(data: final items) when items.isEmpty => const SizedBox.shrink(),
      Success(data: final items) => _buildSuccessState(context, items),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLoadingState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (_minCardWidth).clamp(_minCardWidth, _maxCardWidth);
        final listHeight = cardWidth + _contentHeight;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, onAction: null),
            SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _CardSkeleton(width: cardWidth, height: listHeight),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onAction: null),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 32,
                  color: TradeLinkColors.onSurfaceVariant
                      .withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, List<Listing> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Card width = 40% available width, clamp [130, 170]
        final availableWidth = constraints.maxWidth;
        final cardWidth =
            (availableWidth * 0.40).clamp(_minCardWidth, _maxCardWidth);
        final listHeight = cardWidth + _contentHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, onAction: onViewAll),
            SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: items.length > 8 ? 8 : items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, i) => SizedBox(
                  width: cardWidth,
                  child: ProductCard(
                    item: items[i],
                    layout: ProductCardLayout.vertical,
                    onTap: () => onProductTap(items[i].id),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Skeleton placeholder cho ProductCard trong horizontal list.
class _CardSkeleton extends StatelessWidget {
  final double width;
  final double height;
  const _CardSkeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TradeLinkColors.cardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton — square
          Container(
            height: width,
            decoration: const BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: width - 30,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: width - 50,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
