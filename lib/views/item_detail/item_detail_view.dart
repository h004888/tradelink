import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../models/seller_stats.dart';
import '../../repositories/chat_repository.dart';
import '../../utils/constants.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/item_detail_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class ItemDetailView extends StatelessWidget {
  final String itemId;
  const ItemDetailView({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailViewModel(itemId: itemId),
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
  int _currentImageIndex = 0;
  bool _openingChat = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// Gọi API getOrCreateConversation để có real conversation ID, sau đó navigate.
  /// Dùng `context.go` thay vì `context.push` để tránh Navigator key collision
  /// khi cross-branch navigation (item detail ở branch 0 → chat ở branch 1)
  /// — đây là bug đã biết của GoRouter 14.x với StatefulShellRoute.
  Future<void> _openChat(BuildContext context, String sellerId, String listingId) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);
    try {
      final result = await ChatRepository().getOrCreateConversation(
        sellerId,
        listingId: listingId,
      );
      if (!context.mounted) return;
      switch (result) {
        case ResultSuccess<String>(data: final convId):
          context.go('${AppPaths.chat}/$convId');
        case FailureResult<String>(failure: final err):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở chat: ${err.message}')),
          );
      }
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemDetailViewModel>();

    // Auth Gate: nếu guest bấm Save → redirect login
    if (vm.needsAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        vm.clearNeedsAuth();
        context.push('${AppPaths.login}?redirect=${Uri.encodeComponent('${AppPaths.itemDetail}/${vm.itemId}')}');
      });
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Chi tiết sản phẩm',
        actions: [
          IconButton(
            icon: Icon(
              vm.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: vm.isSaved ? TradeLinkColors.primaryContainer : null,
            ),
            onPressed: vm.toggleSave,
            tooltip: vm.isSaved ? 'Bỏ lưu' : 'Lưu tin',
          ),
        ],
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.detail(),
        Error(message: final m) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được sản phẩm',
            message: m,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success(data: final item) => _buildContent(context, vm, item, theme),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildContent(
      BuildContext context, ItemDetailViewModel vm, Listing item, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Media ──
          _buildMedia(item, theme),
          const SizedBox(height: TradeLinkSpacing.lg),

          // ── 2. Thông tin chính ──
          _buildMainInfo(item, theme),
          const SizedBox(height: TradeLinkSpacing.md),

          // ── Unavailable banner (nếu có) ──
          if (!vm.isListingAvailable && vm.unavailableReason != null) ...[
            _buildUnavailableBanner(vm.unavailableReason!, theme),
            const SizedBox(height: TradeLinkSpacing.md),
          ],

          // ── 3. Mô tả ──
          _buildDescription(item, theme),
          const SizedBox(height: TradeLinkSpacing.md),

          // ── 4. Seller Trust Card ──
          _buildSellerTrustCard(context, item, theme, vm.sellerStats),
          const SizedBox(height: TradeLinkSpacing.md),

          // ── 5. Protection Card ──
          _buildProtectionCard(theme),
          const SizedBox(height: TradeLinkSpacing.md),

          // ── 6. Chi phí dự kiến ──
          _buildCostBreakdown(item, theme),
          const SizedBox(height: TradeLinkSpacing.xl),

          // ── 7. CTA ──
          _buildCTA(context, vm, item),
          const SizedBox(height: TradeLinkSpacing.lg),
        ],
      ),
    );
  }

  // ── 1. Media ──
  Widget _buildMedia(Listing item, ThemeData theme) {
    final images = item.imageUrls;
    final hasImages = images.isNotEmpty;
    final canSwipe = images.length > 1;

    // Không có ảnh → hiện placeholder
    if (!hasImages) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 80, color: TradeLinkColors.outlineVariant),
      );
    }

    // Có ảnh → hiện carousel
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // PageView (swipeable)
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
            // Page indicator dots
            if (canSwipe)
              Positioned(
                left: 0, right: 0, bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) => Container(
                    width: 6, height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  )),
                ),
              ),
            // Image count badge
            if (canSwipe)
              Positioned(
                right: 12, top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54, borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 2. Thông tin chính ──
  Widget _buildMainInfo(Listing item, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 24, fontWeight: FontWeight.w700,
            letterSpacing: -0.01 * 24, height: 1.25,
          ),
        ),
        if (item.price != null) ...[
          const SizedBox(height: TradeLinkSpacing.sm),
          Row(
            children: [
              TradeLinkText.money(item.priceFormatted, size: 'large'),
              const SizedBox(width: 8),
              Flexible(
                child: StatusBadge(
                  type: item.type == ListingType.trade
                      ? TradeLinkBadgeType.trade : TradeLinkBadgeType.escrow,
                  label: item.type == ListingType.trade ? 'Trao đổi' : 'Bán qua escrow',
                  prominent: true,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: TradeLinkSpacing.sm),
        // Location + Time
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: TradeLinkColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(item.location ?? 'Chưa cập nhật',
              style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
            const SizedBox(width: 16),
            Icon(Icons.access_time_outlined, size: 14, color: TradeLinkColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(_formatTimeAgo(item.createdAt),
              style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: TradeLinkSpacing.xs),
        // Views + Interests
        Row(
          children: [
            Icon(Icons.visibility_outlined, size: 14, color: TradeLinkColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('${item.views} lượt xem',
              style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
            const SizedBox(width: 16),
            Icon(Icons.favorite_outline, size: 14, color: TradeLinkColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('${item.interests} quan tâm',
              style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  // ── 3. Mô tả ──
  Widget _buildDescription(Listing item, ThemeData theme) {
    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mô tả chi tiết',
              style: theme.textTheme.labelLarge?.copyWith(
                color: TradeLinkColors.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          const SizedBox(height: TradeLinkSpacing.xs),
          Text(item.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: TradeLinkSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(label: 'Tình trạng: ${item.condition.name}'),
              _InfoChip(label: 'Danh mục: ${item.categoryName ?? item.category}'),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Seller Trust Card ──
  Widget _buildSellerTrustCard(BuildContext context, Listing item, ThemeData theme, SellerStats? stats) {
    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      onTap: () => context.push('${AppPaths.sellerProfile}/${item.sellerId}'),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.surfaceContainerHigh,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline, color: TradeLinkColors.onSurfaceVariant),
          ),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(stats?.sellerName ?? item.sellerName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Icon(Icons.verified, size: 16, color: TradeLinkColors.tradeTeal),
                    const SizedBox(width: 4),
                    Text('Đã xác thực', style: TextStyle(fontSize: 11, color: TradeLinkColors.tradeTeal)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${item.categoryName ?? item.category} • ${item.condition.name}',
                    style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant)),
                // Stats from API
                if (stats != null)
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: TradeLinkColors.escrowAmber),
                      Text(' ${stats.ratingFormatted}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(' (${stats.totalTransactions} giao dịch)',
                        style: TextStyle(fontSize: 11, color: TradeLinkColors.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Icon(Icons.timer_outlined, size: 12, color: TradeLinkColors.onSurfaceVariant),
                      Text(' ${stats.responseTime}',
                        style: TextStyle(fontSize: 11, color: TradeLinkColors.onSurfaceVariant)),
                    ],
                  )
                else
                  // Loading skeleton
                  Row(
                    children: [
                      Container(width: 120, height: 14,
                        decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: TradeLinkColors.onSurfaceVariant),
        ],
      ),
    );
  }

  // ── 5. Protection Card ──
  Widget _buildProtectionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      decoration: BoxDecoration(
        color: TradeLinkColors.tradeTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
        border: Border.all(
          color: TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: TradeLinkColors.tradeTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.shield_outlined, size: 22, color: TradeLinkColors.tradeTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Được bảo vệ bởi TradeLink',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: TradeLinkColors.tradeTeal)),
                const SizedBox(height: 4),
                Text('Tiền được giữ trong quá trình giao dịch. Người bán chỉ nhận tiền khi giao dịch hoàn tất. Bạn có thể báo vấn đề trong thời gian kiểm tra.',
                    style: TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Chi phí dự kiến ──
  Widget _buildCostBreakdown(Listing item, ThemeData theme) {
    if (item.price == null) return const SizedBox.shrink();
    const feeRate = 0.02; // 2% phí bảo vệ
    const shippingFee = 30000.0; // Phí ship ước tính cố định
    final price = item.price!;
    final protectionFee = price * feeRate;
    final total = price + protectionFee + shippingFee;

    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi phí dự kiến',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          _buildCostRow('Giá sản phẩm', price),
          _buildCostRow('Phí bảo vệ', protectionFee),
          _buildCostRow('Phí vận chuyển ước tính', shippingFee),
          const Divider(height: 20),
          _buildCostRow('Tổng dự kiến', total, bold: true),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(
            formatVnd(amount),
            style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Unavailable banner ──
  Widget _buildUnavailableBanner(String reason, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TradeLinkColors.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TradeLinkColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: TradeLinkColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(reason, style: TextStyle(color: TradeLinkColors.error, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ── 7. CTA ──
  Widget _buildCTA(BuildContext context, ItemDetailViewModel vm, Listing item) {
    // Nếu là seller → "Quản lý tin đăng"
    if (vm.isCurrentUserSeller) {
      return SizedBox(
        width: double.infinity,
        child: TradeLinkButton.cta(
          label: 'Quản lý tin đăng',
          icon: Icons.inventory_2_outlined,
          onPressed: () => context.push('${AppPaths.listingDetail}/${item.id}'),
        ),
      );
    }

    // Nếu listing unavailable → ẩn CTA
    if (!vm.isListingAvailable) {
      return const SizedBox.shrink();
    }

    // Buyer actions
    // "Mua an toàn" chỉ áp dụng cho tin có thể bán trực tiếp (sale/both) —
    // tin type=trade thuần không có giá bán nên không tạo được giao dịch escrow kiểu sale.
    final canBuyDirectly = item.type != ListingType.trade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canBuyDirectly) ...[
          // CTA chính: Mua an toàn — dùng context.go (cross-branch sang Transactions)
          TradeLinkButton.cta(
            label: 'Mua an toàn',
            icon: Icons.shopping_cart_outlined,
            onPressed: () => context.go('${AppPaths.createOrder}/${item.id}'),
          ),
          const SizedBox(height: TradeLinkSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: TradeLinkButton.secondary(
                label: 'Gửi offer',
                icon: Icons.send_outlined,
                // Same branch (Home sub-route) → push OK
                onPressed: () => context.push('${AppPaths.sendOffer}/${item.id}'),
              ),
            ),
            const SizedBox(width: TradeLinkSpacing.sm),
            Expanded(
              child: TradeLinkButton.secondary(
                label: 'Nhắn người bán',
                icon: Icons.chat_bubble_outline,
                // Disable khi đang gọi API; spinner không có sẵn trên secondary button
                onPressed: _openingChat
                    ? null
                    : () => _openChat(context, item.sellerId, item.id),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    return '${diff.inMinutes} phút trước';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: TradeLinkColors.onSurfaceVariant)),
    );
  }
}
