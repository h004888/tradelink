import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/watchlist_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WatchlistViewModel()..load(),
      child: const _WatchlistBody(),
    );
  }
}

class _WatchlistBody extends StatelessWidget {
  const _WatchlistBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchlistViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Tin đã lưu',
        subtitle: 'Danh sách theo dõi của bạn',
      ),
      body: vm.isLoading
          ? const LoadingSkeleton.card()
          : vm.isEmpty
              ? EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Chưa có tin đã lưu',
                  message:
                      'Lưu các tin đăng bạn quan tâm để theo dõi giá và không bỏ lỡ cơ hội.',
                  actionLabel: 'Khám phá ngay',
                  onAction: () => context.go(AppPaths.home),
                )
              : GridView.builder(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: TradeLinkSpacing.sm,
              mainAxisSpacing: TradeLinkSpacing.sm,
              // Aspect ratio 0.65 — content gồm: image vuông (158px) +
              // 2 dòng title (~36px) + xs gap (4) + price compact (~20) +
              // padding 16 = ~234px. Card height = 158/0.65 = 243 → margin 9px
              // Fix "BOTTOM OVERFLOWED BY 37 PIXELS" (overflow 37px với 0.78)
              childAspectRatio: 0.65,
            ),
            itemCount: vm.items.length,
            itemBuilder: (_, i) {
              final item = vm.items[i];
              return TradeLinkCard(
                // Click từ watchlist (BUYER) → navigate tới ItemDetailView
                // (top-level route, có sẵn logic check `isCurrentUserSeller`:
                // - Seller → "Quản lý tin đăng"
                // - Buyer → "Mua an toàn" / "Gửi offer" / "Nhắn người bán")
                //
                // Dùng `context.go` thay vì `context.push` để tránh key collision
                onTap: item.id.isEmpty
                    ? null
                    : () => context.go('${AppPaths.itemDetail}/${item.id}'),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(TradeLinkRadii.lg),
                            ),
                            child: _WatchlistImage(
                              url: item.imageUrls.isNotEmpty
                                  ? item.imageUrls.first
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          top: TradeLinkSpacing.xs,
                          right: TradeLinkSpacing.xs,
                          child: _UnsaveButton(
                            onPressed: item.id.isEmpty
                                ? null
                                : () => context
                                    .read<WatchlistViewModel>()
                                    .remove(item.id),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title.isEmpty ? 'Đang tải...' : item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                          ),
                          const SizedBox(height: TradeLinkSpacing.xs),
                          TradeLinkText.money(
                            item.priceFormatted,
                            size: 'compact',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

/// Nút bỏ lưu nổi trên góc ảnh — gọi trực tiếp WatchlistViewModel.remove()
class _UnsaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _UnsaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.bookmark_remove_outlined,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Widget load ảnh từ URL với placeholder + error fallback
class _WatchlistImage extends StatelessWidget {
  final String? url;
  const _WatchlistImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: TradeLinkColors.surfaceContainerHigh,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 40,
          color: TradeLinkColors.outlineVariant,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => Container(
        color: TradeLinkColors.surfaceContainerHigh,
      ),
      errorWidget: (_, _, _) => Container(
        color: TradeLinkColors.surfaceContainerHigh,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: TradeLinkColors.outlineVariant,
        ),
      ),
    );
  }
}