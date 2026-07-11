import 'package:flutter/material.dart';

import '../core/ui_state.dart';
import '../models/listing_model.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';

/// Section sản phẩm có header + horizontal list + states.
///
/// Dùng cho cả "Gần bạn" và "Mới đăng".
class ProductSection extends StatelessWidget {
  final String title;
  final UiState<List<Listing>> state;
  final VoidCallback? onViewAll;
  final void Function(String id) onProductTap;

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
      Loading() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, onAction: null),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: 4,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _CardSkeleton(),
                ),
              ),
            ),
          ],
        ),
      Error(message: final m, retryable: true) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, onAction: null),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 32, color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text(
                      m,
                      style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      Success(data: final items) when items.isEmpty => const SizedBox.shrink(),
      Success(data: final items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, onAction: onViewAll),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: items.length > 8 ? 8 : items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(
                  width: 130,
                  child: ProductCard(
                    item: items[i],
                    layout: ProductCardLayout.vertical,
                    onTap: () => onProductTap(items[i].id),
                  ),
                ),
              ),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Skeleton placeholder cho ProductCard trong horizontal list
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 100,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
