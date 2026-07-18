import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/ui_state.dart';
import '../../repositories/chat_repository.dart';
import '../../utils/theme.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';

class ChatView extends StatelessWidget {
  final String conversationId;
  final String? offerListingId;
  const ChatView({
    super.key,
    required this.conversationId,
    this.offerListingId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        conversationId: conversationId,
        offerListingId: offerListingId,
      ),
      child: const _ChatBody(),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();
  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;
  int _unreadCount = 0;
  bool _initialized = false;

  /// Threshold (pixels) để coi user là "gần bottom" → auto-scroll
  /// Nếu user scroll lên xa hơn threshold này → hiện badge "Tin nhắn mới"
  static const double _bottomThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Check user có đang ở gần bottom của list không
  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent == 0) return true; // List rỗng
    return pos.pixels >= pos.maxScrollExtent - _bottomThreshold;
  }

  /// Scroll listener — khi user scroll xuống gần bottom, reset unread count
  void _onScroll() {
    if (_unreadCount > 0 && _isNearBottom) {
      setState(() => _unreadCount = 0);
    }
  }

  /// Scroll xuống bottom với animation mượt (đợi 1 frame để layout settle)
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 16), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  /// User bấm vào badge "Tin nhắn mới" → scroll xuống + reset count
  void _scrollToNewMessage() {
    _scrollToBottom();
    if (_unreadCount > 0) setState(() => _unreadCount = 0);
  }

  Future<void> _send(ChatViewModel vm) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Disable send during in-flight to prevent double-tap
    if (vm.sendState is Loading) return;

    _textController.clear();
    await vm.sendMessage(text);
    // Build() sẽ tự detect count tăng → scroll hoặc badge.
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final theme = Theme.of(context);

    // ── Auto-scroll / unread badge logic ──
    // Detect new messages từ socket hoặc sau send:
    // - Lần đầu mở chat: scroll xuống tin mới nhất, không badge
    // - User ở gần bottom: auto-scroll, không badge
    // - User scroll lên trên: hiện badge "↓ Tin nhắn mới"
    final currentCount = vm.state is Success<List<ChatMessage>>
        ? (vm.state as Success<List<ChatMessage>>).data.length
        : 0;

    if (!_initialized) {
      _initialized = true;
      _lastMessageCount = currentCount;
      if (currentCount > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } else if (currentCount > _lastMessageCount) {
      _lastMessageCount = currentCount;
      if (_isNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _unreadCount++);
        });
      }
    } else {
      _lastMessageCount = currentCount;
    }

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Thương lượng',
        subtitle: 'Trao đổi về sản phẩm',
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                switch (vm.state) {
                  Loading() => const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Error(message: final m) => EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'Không tải được tin nhắn',
                      message: m,
                      actionLabel: 'Thử lại',
                      onAction: vm.load,
                    ),
                  Success(data: final msgs) => ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(TradeLinkSpacing.md),
                      itemCount: msgs.length,
                      itemBuilder: (_, i) {
                        final msg = msgs[i];
                        final isMe = msg.senderId == ApiClient.instance.getUserId();
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: TradeLinkSpacing.xs),
                            padding: const EdgeInsets.symmetric(
                              horizontal: TradeLinkSpacing.sm,
                              vertical: TradeLinkSpacing.sm,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? TradeLinkColors.primaryContainer
                                  : TradeLinkColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(TradeLinkRadii.md),
                                topRight: const Radius.circular(TradeLinkRadii.md),
                                bottomLeft: isMe
                                    ? const Radius.circular(TradeLinkRadii.md)
                                    : Radius.zero,
                                bottomRight: isMe
                                    ? Radius.zero
                                    : const Radius.circular(TradeLinkRadii.md),
                              ),
                              border: isMe
                                  ? null
                                  : Border.all(color: TradeLinkColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      msg.senderName,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: TradeLinkColors.saleBlue,
                                      ),
                                    ),
                                  ),
                                Text(
                                  msg.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    color: isMe
                                        ? Colors.white
                                        : TradeLinkColors.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  _ => const SizedBox.shrink(),
                },
                // Badge "Tin nhắn mới" ở góc dưới bên phải — chỉ hiện khi user scroll lên
                if (_unreadCount > 0)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _NewMessageBadge(
                      count: _unreadCount,
                      onTap: _scrollToNewMessage,
                    ),
                  ),
              ],
            ),
          ),
          // Snackbar lỗi gửi message
          if (vm.sendState is Error)
            Container(
              width: double.infinity,
              color: TradeLinkColors.errorContainer.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: TradeLinkColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (vm.sendState as Error).message,
                      style: const TextStyle(fontSize: 12, color: TradeLinkColors.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Retry với text hiện tại
                      final t = _textController.text.trim();
                      if (t.isNotEmpty) _send(vm);
                    },
                    child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          // Input area
          Container(
            decoration: const BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: TradeLinkColors.cardDivider)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vm.sendAsOffer)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        TradeLinkSpacing.sm,
                        TradeLinkSpacing.xs,
                        TradeLinkSpacing.sm,
                        0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TradeLinkSpacing.sm,
                          vertical: TradeLinkSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: TradeLinkColors.saleBlue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              size: 16,
                              color: TradeLinkColors.saleBlue,
                            ),
                            const SizedBox(width: TradeLinkSpacing.xs),
                            const Expanded(
                              child: Text(
                                'Sẽ gửi kèm đề nghị mua hàng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TradeLinkColors.saleBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: vm.toggleSendAsOffer,
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: TradeLinkColors.saleBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(TradeLinkSpacing.xs),
                    child: Row(
                      children: [
                        if (vm.offerListingId != null)
                          IconButton(
                            icon: Icon(
                              Icons.local_offer_outlined,
                              color: vm.sendAsOffer
                                  ? TradeLinkColors.saleBlue
                                  : TradeLinkColors.onSurfaceVariant,
                            ),
                            tooltip: 'Gửi kèm đề nghị',
                            onPressed: vm.toggleSendAsOffer,
                          ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: TradeLinkColors.surface,
                              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                              border: Border.all(color: TradeLinkColors.cardBorder),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: TradeLinkSpacing.sm,
                            ),
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: vm.sendState is Loading
                                    ? 'Đang gửi...'
                                    : 'Nhập tin nhắn...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              enabled: vm.sendState is! Loading,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: vm.sendState is Loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TradeLinkColors.primaryContainer,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          color: TradeLinkColors.primaryContainer,
                          onPressed: vm.sendState is Loading ? null : () => _send(vm),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge "Tin nhắn mới" — hiện ở góc dưới bên phải khi user scroll lên đọc lịch sử
class _NewMessageBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NewMessageBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TradeLinkColors.primaryContainer,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      shadowColor: TradeLinkColors.primaryContainer.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                count > 1 ? '$count tin nhắn mới' : 'Tin nhắn mới',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}