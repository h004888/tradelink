import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../repositories/notification_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

String? notificationRoute(AppNotification n) {
  final deeplink = n.deeplink;
  if (deeplink != null && deeplink.startsWith('/')) return deeplink;

  final entityId = n.entityId;
  switch (n.entityType) {
    case 'conversation':
      return entityId == null || entityId.isEmpty
          ? null
          : '${AppPaths.chat}/$entityId';
    case 'transaction':
      return entityId == null || entityId.isEmpty
          ? null
          : '${AppPaths.transactionSale}/$entityId';
    case 'wallet':
      return AppPaths.wallet;
    case 'offer':
      return AppPaths.offersList;
  }

  final id = n.relatedId;
  if (id == null || id.isEmpty) return null;
  return switch (n.type) {
    NotificationType.chat => '${AppPaths.chat}/$id',
    NotificationType.transaction => '${AppPaths.transactionSale}/$id',
    NotificationType.offer => AppPaths.offersList,
    NotificationType.system => '${AppPaths.itemDetail}/$id',
    NotificationType.wallet => AppPaths.wallet,
    NotificationType.dispute => null,
  };
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  IconData _icon(NotificationType t) => switch (t) {
    NotificationType.transaction => Icons.swap_horiz,
    NotificationType.chat => Icons.chat_bubble_outline,
    NotificationType.dispute => Icons.warning_amber_outlined,
    NotificationType.offer => Icons.local_offer_outlined,
    NotificationType.wallet => Icons.account_balance_wallet_outlined,
    NotificationType.system => Icons.info_outline,
  };

  Color _color(NotificationType t) => switch (t) {
    NotificationType.transaction => TradeLinkColors.tradeTeal,
    NotificationType.chat => TradeLinkColors.actionBlue,
    NotificationType.dispute => TradeLinkColors.disputeRed,
    NotificationType.offer => TradeLinkColors.saleBlue,
    NotificationType.wallet => TradeLinkColors.success,
    NotificationType.system => TradeLinkColors.onSurfaceVariant,
  };

  /// Điều hướng theo type — chỉ dùng relatedId khi biết chắc nó trỏ đúng đối tượng
  /// (xem ghi chú ở từng case). Không rõ/không an toàn → không điều hướng, chỉ đánh dấu đã đọc.
  void _handleTap(
    BuildContext context,
    NotificationsViewModel vm,
    AppNotification n,
  ) {
    vm.markRead(n.id);
    final route = notificationRoute(n);
    if (route == null) return;
    if (route.startsWith(AppPaths.chat) ||
        route.startsWith(AppPaths.transactionSale)) {
      context.go(route);
      return;
    }
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    final theme = Theme.of(context);
    final hasUnread =
        vm.state is Success<List<AppNotification>> &&
        (vm.state as Success<List<AppNotification>>).data.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Thông báo',
        subtitle: 'Cập nhật giao dịch và tin nhắn',
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: vm.markAllRead,
              child: const Text('Đọc tất cả', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.list(itemCount: 6),
        Error(message: final m) => EmptyState(
          icon: Icons.notifications_off_outlined,
          title: 'Không tải được thông báo',
          message: m,
          actionLabel: 'Thử lại',
          onAction: vm.load,
        ),
        Success(data: final list) =>
          list.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'Chưa có thông báo',
                  message:
                      'Thông báo về giao dịch, tin nhắn và cập nhật hệ thống sẽ hiển thị ở đây.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: TradeLinkSpacing.sm),
                  itemBuilder: (_, i) {
                    final n = list[i];
                    final color = _color(n.type);
                    return TradeLinkCard(
                      onTap: () => _handleTap(context, vm, n),
                      padding: const EdgeInsets.all(TradeLinkSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: n.isRead ? 0.06 : 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(_icon(n.type), color: color, size: 22),
                          ),
                          const SizedBox(width: TradeLinkSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: n.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                              color: TradeLinkColors.onSurface,
                                            ),
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color:
                                              TradeLinkColors.primaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.body,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: TradeLinkColors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
