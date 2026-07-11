import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/listing_model.dart';
import '../utils/theme.dart';

/// Kiểu layout cho ProductCard
enum ProductCardLayout {
  /// Vertical: image trên, title + price dưới — dùng cho grid
  vertical,

  /// Horizontal: image trái, title + price phải — dùng cho search results
  horizontal,
}

/// ProductCard chuẩn hóa, reusable toàn ứng dụng.
///
/// Hỗ trợ:
/// - Layout vertical (home grid) và horizontal (search results)
/// - Image loading với placeholder + error fallback
/// - Title max 2 dòng + ellipsis — không overflow
/// - Price format VND / "Trao đổi"
class ProductCard extends StatelessWidget {
  final Listing item;
  final ProductCardLayout layout;
  final double? imageSize; // Chỉ dùng cho horizontal layout
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.item,
    this.layout = ProductCardLayout.vertical,
    this.imageSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: layout == ProductCardLayout.horizontal
          ? _buildHorizontal()
          : _buildVertical(),
    );
  }

  Widget _buildVertical() {
    return Container(
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TradeLinkColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Image area
        AspectRatio(
          aspectRatio: 1.0,
          child: _buildImage(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: _buildContent(),
        ),
      ]),
    );
  }

  Widget _buildHorizontal() {
    final size = imageSize ?? 72.0;
    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildImage(
            borderRadius: BorderRadius.circular(TradeLinkRadii.md),
          ),
        ),
        const SizedBox(width: TradeLinkSpacing.sm),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildImage({BorderRadius? borderRadius}) {
    final hasImage = item.imageUrls.isNotEmpty;
    final imageUrl = hasImage ? item.imageUrls.first : null;

    // Hàm fallback widget cho trường hợp không có ảnh hoặc load lỗi
    Widget fallback() => Container(
          decoration: BoxDecoration(
            color: TradeLinkColors.surfaceContainerHigh,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 32, color: TradeLinkColors.outlineVariant),
        );

    if (imageUrl == null || imageUrl.isEmpty) return fallback();

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: TradeLinkColors.surfaceContainerHigh,
          child: const Icon(Icons.image_outlined, size: 32, color: TradeLinkColors.outlineVariant),
        ),
        errorWidget: (_, _, _) => fallback(),
      ),
    );
  }

  Widget _buildContent() {
    final isTrade = item.type == ListingType.trade;
    final priceColor = isTrade ? TradeLinkColors.tradeTeal : TradeLinkColors.saleBlue;
    final priceText = item.priceFormatted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
        ),
        const SizedBox(height: 4),
        Text(
          priceText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: layout == ProductCardLayout.horizontal ? 14 : 15,
            fontWeight: FontWeight.w700,
            color: priceColor,
          ),
        ),
      ],
    );
  }
}
