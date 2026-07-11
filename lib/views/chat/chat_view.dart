import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(ChatViewModel vm) {
    if (_textController.text.trim().isEmpty) return;
    vm.sendMessage(_textController.text.trim());
    _textController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Thương lượng',
        subtitle: 'Trao đổi về sản phẩm',
      ),
      body: Column(
        children: [
          Expanded(
            child: switch (vm.state) {
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
                    final isMe = msg.senderId == 'user-001';
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
                              decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: TradeLinkColors.primaryContainer,
                          onPressed: () => _send(vm),
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