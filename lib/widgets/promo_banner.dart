import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui_state.dart';
import '../models/listing_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Banner khuyến mãi trên Home — carousel các tin đăng đang được boost.
/// Ẩn hoàn toàn nếu chưa có tin nào được boost (không hiển thị nội dung giả).
class PromoBanner extends StatefulWidget {
  final UiState<List<Listing>> state;
  const PromoBanner({super.key, required this.state});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.state) {
      Loading() => _buildSkeleton(),
      Success(data: final items) when items.isNotEmpty => _buildCarousel(items),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<Listing> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _BannerCard(item: items[i]),
              ),
            ),
          ),
          if (items.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? TradeLinkColors.primaryContainer
                        : TradeLinkColors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Listing item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppPaths.itemDetail}/${item.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrls.isNotEmpty)
              Image.network(
                item.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: TradeLinkColors.surfaceContainerHigh),
              )
            else
              Container(color: TradeLinkColors.surfaceContainerHigh),
            // Gradient overlay để chữ dễ đọc
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TradeLinkColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ƯU ĐÃI NỔI BẬT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.priceFormatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
