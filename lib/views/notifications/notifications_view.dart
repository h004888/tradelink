import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../repositories/notification_repository.dart';
import '../../utils/theme.dart';
import '../../viewmodels/notifications_viewmodel.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => NotificationsViewModel(), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  IconData _icon(NotificationType t) => switch (t) { NotificationType.transaction => Icons.swap_horiz, NotificationType.chat => Icons.chat_outlined, NotificationType.dispute => Icons.warning_outlined, NotificationType.system => Icons.info_outlined, };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Thông báo')),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Text(m)),
        Success(data: final list) => ListView.separated(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final n = list[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: n.isRead ? TradeLinkColors.surfaceContainerLowest : TradeLinkColors.primaryFixedDim.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(TradeLinkRadii.lg)),
                child: Row(children: [
                  Icon(_icon(n.type), color: TradeLinkColors.primaryContainer, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(n.body, style: const TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                ]),
              );
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
