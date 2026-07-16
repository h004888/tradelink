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
              childAspectRatio: 0.72,
            ),
            itemCount: vm.items.length,
            itemBuilder: (_, i) {
              final item = vm.items[i];
              return TradeLinkCard(
                onTap: () =>
                    context.push('${AppPaths.itemDetail}/${item.id}'),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: TradeLinkColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(TradeLinkRadii.lg),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: TradeLinkColors.outlineVariant,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
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