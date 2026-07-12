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
/// - Image loading với skeleton placeholder
/// - Image empty: icon + text "Không có ảnh"
/// - Image error: icon + text lỗi + tap để thử lại
/// - Title max 2 dòng, chiều cao cố định → giá thẳng hàng giữa các card
/// - Price format VNĐ / "Trao đổi", không tách dòng ₫
/// - Padding & spacing đồng nhất theo DESIGN.md
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

  // ── Constants cho layout đồng nhất ──
  static const _cardRadius = 16.0;
  static const _contentPaddingH = 12.0;
  static const _contentPaddingTop = 12.0;
  static const _contentPaddingBottom = 16.0;
  static const _gapTitleToPrice = 8.0;

  /// Chiều cao cố định cho vùng tên = 2 dòng text.
  /// fontSize=12 × lineHeight=1.3 × 2 dòng = 31.2 → làm tròn 32.
  static const _titleHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: layout == ProductCardLayout.horizontal
          ? _buildHorizontal()
          : _buildVertical(),
    );
  }

  // ── Vertical Layout ──────────────────────────

  Widget _buildVertical() {
    return Container(
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: TradeLinkColors.cardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image area — AspectRatio 1:1, BoxFit.cover
          AspectRatio(
            aspectRatio: 1.0,
            child: _ProductImage(
              imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(_cardRadius)),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _contentPaddingH,
              _contentPaddingTop,
              _contentPaddingH,
              _contentPaddingBottom,
            ),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  // ── Horizontal Layout ────────────────────────

  Widget _buildHorizontal() {
    final size = imageSize ?? 72.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _ProductImage(
            imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
            borderRadius: BorderRadius.circular(TradeLinkRadii.md),
          ),
        ),
        const SizedBox(width: TradeLinkSpacing.sm),
        Expanded(child: _buildContent()),
      ],
    );
  }

  // ── Content (title + price) ──────────────────

  Widget _buildContent() {
    final isTrade = item.type == ListingType.trade;
    final priceColor =
        isTrade ? TradeLinkColors.tradeTeal : TradeLinkColors.saleBlue;
    final priceText = item.priceFormatted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vùng tên — chiều cao cố định 2 dòng
        SizedBox(
          height: _titleHeight,
          child: Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: _gapTitleToPrice),
        // Giá — max 1 dòng, không tách ₫
        Text(
          priceText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: layout == ProductCardLayout.horizontal ? 14 : 15,
            fontWeight: FontWeight.w700,
            color: priceColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// _ProductImage — StatefulWidget xử lý 3 trạng thái ảnh
// ─────────────────────────────────────────────────

class _ProductImage extends StatefulWidget {
  final String? imageUrl;
  final BorderRadius? borderRadius;

  const _ProductImage({this.imageUrl, this.borderRadius});

  @override
  State<_ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<_ProductImage> {
  /// Key thay đổi để retry load ảnh khi lỗi.
  UniqueKey _retryKey = UniqueKey();

  void _retry() {
    setState(() {
      _retryKey = UniqueKey();
    });
  }

  bool get _hasImage =>
      widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasImage) {
      return _buildEmpty();
    }

    return ClipRRect(
      key: _retryKey,
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoading(),
        errorWidget: (context, url, error) => _buildError(),
      ),
    );
  }

  /// Loading skeleton — màu nền + shimmer effect đơn giản
  Widget _buildLoading() {
    return Container(
      color: TradeLinkColors.surfaceContainerHigh,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: TradeLinkColors.outlineVariant,
        ),
      ),
    );
  }

  /// Không có ảnh — icon + text rõ ràng
  Widget _buildEmpty() {
    return Container(
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerHigh,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 28,
              color: TradeLinkColors.outlineVariant,
            ),
            const SizedBox(height: 6),
            Text(
              'Không có ảnh',
              style: TextStyle(
                fontSize: 11,
                color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lỗi tải ảnh — icon lỗi + text + tap để thử lại
  Widget _buildError() {
    return GestureDetector(
      onTap: _retry,
      child: Container(
        color: TradeLinkColors.surfaceContainerHigh,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 28,
                color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Lỗi tải ảnh',
                style: TextStyle(
                  fontSize: 11,
                  color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chạm để thử lại',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: TradeLinkColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
