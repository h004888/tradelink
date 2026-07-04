import '../../core/result.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isOffer;
  final String? offerListingId;

  const ChatMessage({
    required this.id, required this.senderId, required this.senderName,
    required this.text, required this.timestamp, this.isOffer = false, this.offerListingId,
  });
}

class ChatRepository {
  final List<ChatMessage> _messages = [
    ChatMessage(id: '1', senderId: 'user-001', senderName: 'Bạn', text: 'Chào bạn, mình quan tâm đến Sony A7IV', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
    ChatMessage(id: '2', senderId: 'user-002', senderName: 'Người bán', text: 'Chào bạn, máy còn mới 99% nhé', timestamp: DateTime.now().subtract(const Duration(minutes: 28))),
    ChatMessage(id: '3', senderId: 'user-001', senderName: 'Bạn', text: 'Mình trả 42 triệu được không?', timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
  ];

  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ResultSuccess(_messages);
  }

  Future<Result<ChatMessage>> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final msg = ChatMessage(id: '${DateTime.now().millisecondsSinceEpoch}', senderId: 'user-001', senderName: 'Bạn', text: text, timestamp: DateTime.now());
    return ResultSuccess(msg);
  }
}
