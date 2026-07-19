import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui_state.dart';
import '../../repositories/chat_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(),
      child: const _ChatListBody(),
    );
  }
}

class _ChatListBody extends StatelessWidget {
  const _ChatListBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tin nhắn', style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
        backgroundColor: TradeLinkColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: switch (vm.state) {
        Loading() => const LoadingSkeleton.list(),
        Error(message: final m, retryable: true) => Center(
            child: EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được tin nhắn',
              message: m,
              actionLabel: 'Thử lại',
              onAction: vm.load,
            ),
          ),
        Success(data: final items) when items.isEmpty => Center(
            child: EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chưa có tin nhắn nào',
              message: 'Khi bạn nhắn tin với người bán hoặc người mua, cuộc hội thoại sẽ hiển thị ở đây.',
              actionLabel: 'Khám phá sản phẩm',
              onAction: () => context.go(AppPaths.home),
            ),
          ),
        Success(data: final items) => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) => _ConversationTile(
              conversation: items[i],
              onTap: () => context.push('/chat/${items[i].id}'),
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: TradeLinkColors.surfaceContainerHigh,
        child: Text(
          (conversation.otherUserName ?? '?')[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TradeLinkColors.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        conversation.otherUserName ?? 'Người dùng',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'Nhấn để xem tin nhắn',
        style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(conversation.updatedAt),
        style: TextStyle(
          fontSize: 12,
          color: TradeLinkColors.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Format thời gian: "Vừa xong" / "HH:mm" / "dd/MM"
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 24 && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
