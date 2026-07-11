import '../core/api_client.dart';
import '../core/result.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isOffer;
  final String? offerListingId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isOffer = false,
    this.offerListingId,
  });
}

class ChatConversation {
  final String id;
  final List<ChatMessage> messages;
  final String? otherUserName;
  final String? otherUserId;
  final String? listingId;

  const ChatConversation({
    required this.id,
    required this.messages,
    this.otherUserName,
    this.otherUserId,
    this.listingId,
  });
}

class ChatRepository {
  final _api = ApiClient.instance;

  ChatMessage _msgFromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        senderId: j['senderId']?.toString() ?? '',
        senderName: j['senderName'] as String? ?? '',
        text: j['text'] as String? ?? '',
        timestamp: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
        isOffer: j['isOffer'] as bool? ?? false,
        offerListingId: j['offerListingId']?.toString(),
      );

  // E1 — list conversations of current user
  Future<Result<List<ChatConversation>>> getConversations() async {
    final res = await _api.get('/conversations');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<ChatConversation>>(res.failure);
    }
    final data = (res as ResultSuccess<Map<String, dynamic>>).data['data'] as List?;
    final list = (data ?? []).map((raw) {
      final j = raw as Map<String, dynamic>;
      final participants = (j['participants'] as List?)?.map((p) {
        if (p is Map) return {'id': p['_id']?.toString() ?? '', 'name': p['name']?.toString() ?? ''};
        return {'id': p.toString(), 'name': 'User'};
      }).toList() ?? [];
      return ChatConversation(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        messages: const [],
        otherUserName: participants.isNotEmpty ? participants.first['name'] as String? : null,
        otherUserId: participants.isNotEmpty ? participants.first['id'] as String? : null,
        listingId: j['listingId']?.toString(),
      );
    }).toList();
    return ResultSuccess<List<ChatConversation>>(list);
  }

  // E2 — get messages of a conversation
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    final res = await _api.get('/conversations/$conversationId/messages');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<ChatMessage>>(res.failure);
    }
    final data = (res as ResultSuccess<Map<String, dynamic>>).data['data'] as List?;
    final list = (data ?? []).map((m) => _msgFromJson(m as Map<String, dynamic>)).toList();
    return ResultSuccess<List<ChatMessage>>(list);
  }

  // E3 — send message
  Future<Result<ChatMessage>> sendMessage(String conversationId, String text, {bool isOffer = false, String? offerListingId}) async {
    final res = await _api.post('/conversations/$conversationId/messages', body: {
      'text': text,
      'isOffer': isOffer,
      'offerListingId': offerListingId,
    });
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<ChatMessage>(res.failure);
    }
    final msg = _msgFromJson((res as ResultSuccess<Map<String, dynamic>>).data['data'] as Map<String, dynamic>);
    return ResultSuccess<ChatMessage>(msg);
  }

  // E4 — auto-create conversation (or get existing)
  Future<Result<String>> getOrCreateConversation(String otherUserId, {String? listingId}) async {
    // Vì backend route conversations không có endpoint này trực tiếp,
    // gọi /auth/me cho buyer + buyer hiện tại sẽ tự tạo khi send message.
    // Đơn giản: gọi 1 endpoint scan user khác, lấy conversation.
    // Tạm thời: trả về 1 conversationId giả, buyer sẽ create khi sendMessage đầu tiên.
    // Backend chat.service.ts:sendMessage chỉ update Conversation.findByIdAndUpdate
    // → chưa có auto-create. Cần backend hook.
    final res = await _api.post('/conversations/init', body: {'otherUserId': otherUserId, 'listingId': listingId});
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<String>(res.failure);
    }
    final convId = (res as ResultSuccess<Map<String, dynamic>>).data['data']['_id'] as String;
    return ResultSuccess<String>(convId);
  }
}
