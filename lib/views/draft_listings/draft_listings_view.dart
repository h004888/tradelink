import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/draft_listings_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class DraftListingsView extends StatelessWidget {
  const DraftListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DraftListingsViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DraftListingsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Nháp tin đăng'),
      body: vm.isEmpty
          ? EmptyState(
              icon: Icons.note_add_outlined,
              title: 'Chưa có tin nháp',
              message: 'Tin nháp được lưu trên thiết bị của bạn để chỉnh sửa sau.',
              actionLabel: 'Tạo tin mới',
              onAction: () => context.push(AppPaths.createListing),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              itemCount: vm.drafts.length,
              itemBuilder: (_, i) {
                final d = vm.drafts[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
                  child: Dismissible(
                    key: Key(d.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: TradeLinkSpacing.lg),
                      decoration: BoxDecoration(
                        color: TradeLinkColors.error,
                        borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) => vm.deleteDraft(i),
                    child: TradeLinkCard(
                      onTap: () => context.push(AppPaths.createListing),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TradeLinkSpacing.md,
                        vertical: TradeLinkSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: TradeLinkColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.drafts_outlined,
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: TradeLinkSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.title.isEmpty ? 'Chưa có tiêu đề' : d.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Đã lưu lúc ${d.createdAt.hour}:${d.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: TradeLinkColors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: TradeLinkSpacing.xs),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          TradeLinkRadii.full,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: d.completionPercent / 100,
                                          minHeight: 4,
                                          backgroundColor:
                                              TradeLinkColors.surfaceContainerHigh,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            TradeLinkColors.successGreen,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: TradeLinkSpacing.xs),
                                    Text(
                                      '${d.completionPercent}%',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            color: TradeLinkColors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: TradeLinkColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppPaths.createListing),
        backgroundColor: TradeLinkColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo tin mới'),
      ),
    );
  }
}