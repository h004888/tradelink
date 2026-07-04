import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/chat_viewmodel.dart';

class ChatView extends StatelessWidget {
  final String conversationId;
  const ChatView({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ChatViewModel(conversationId: conversationId), child: const _ChatBody());
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
  void dispose() { _textController.dispose(); _scrollController.dispose(); super.dispose(); }

  void _send(ChatViewModel vm) {
    if (_textController.text.trim().isEmpty) return;
    vm.sendMessage(_textController.text.trim());
    _textController.clear();
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Thương lượng')),
      body: Column(children: [
        Expanded(
          child: switch (vm.state) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Error(message: final m) => Center(child: Text(m)),
            Success(data: final msgs) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final msg = msgs[i];
                  final isMe = msg.senderId == 'user-001';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isMe ? TradeLinkColors.primaryContainer : TradeLinkColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12), topRight: const Radius.circular(12),
                          bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                          bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (!isMe) Text(msg.senderName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TradeLinkColors.saleBlue)),
                        const SizedBox(height: 2),
                        Text(msg.text, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : TradeLinkColors.onSurface)),
                      ]),
                    ),
                  );
                },
              ),
            _ => const SizedBox.shrink(),
          },
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, border: Border(top: BorderSide(color: TradeLinkColors.cardDivider))),
          child: Row(children: [
            Expanded(child: TextField(controller: _textController, decoration: const InputDecoration(hintText: 'Nhập tin nhắn...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)))),
            IconButton(icon: const Icon(Icons.send, color: TradeLinkColors.primaryContainer), onPressed: () => _send(vm)),
          ]),
        ),
      ]),
    );
  }
}
