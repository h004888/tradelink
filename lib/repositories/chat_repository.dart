import '../core/api_client.dart';
import '../core/result.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isOffer;
  final String? offerListingId;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.isOffer = false,
    this.offerListingId,
    this.readBy = const [],
  });

  /// Đã được người khác (ngoài người gửi) đọc chưa — dùng để hiện tick "đã xem".
  bool get isSeenByOther => readBy.any((id) => id != senderId);

  ChatMessage copyWithReadBy(List<String> readBy) => ChatMessage(
        id: id,
        senderId: senderId,
        senderName: senderName,
        text: text,
        imageUrl: imageUrl,
        timestamp: timestamp,
        isOffer: isOffer,
        offerListingId: offerListingId,
        readBy: readBy,
      );
}

class ChatConversation {
  final String id;
  final List<ChatMessage> messages;
  final String? otherUserName;
  final String? otherUserId;
  final String? listingId;

  /// Last message preview — dùng cho subtitle trong chat list
  final String? lastMessage;

  /// Thời gian cập nhật cuối — dùng cho sort/timestamp
  final DateTime? updatedAt;

  const ChatConversation({
    required this.id,
    required this.messages,
    this.otherUserName,
    this.otherUserId,
    this.listingId,
    this.lastMessage,
    this.updatedAt,
  });
}

class ChatRepository {
  final _api = ApiClient.instance;

  ChatMessage _msgFromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        senderId: j['senderId']?.toString() ?? '',
        senderName: j['senderName'] as String? ?? '',
        text: j['text'] as String? ?? '',
        imageUrl: j['imageUrl'] as String?,
        timestamp: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
        isOffer: j['isOffer'] as bool? ?? false,
        offerListingId: j['offerListingId']?.toString(),
        readBy: ((j['readBy'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  // E1 — list conversations of current user
  Future<Result<List<ChatConversation>>> getConversations() async {
    final res = await _api.get('/conversations');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<ChatConversation>>(res.failure);
    }
    final data = (res as ResultSuccess<Map<String, dynamic>>).data['data'] as List?;
    final currentUserId = _api.getUserId();
    final list = (data ?? []).map((raw) {
      final j = raw as Map<String, dynamic>;
      final participants = (j['participants'] as List?)?.map((p) {
        if (p is Map) return {'id': p['_id']?.toString() ?? '', 'name': p['name']?.toString() ?? ''};
        return {'id': p.toString(), 'name': 'User'};
      }).toList() ?? [];
      // Lọc ra người chat còn lại (không phải current user) — tránh hiển thị tên chính mình
      final others = participants.where((p) => p['id'] != currentUserId).toList();
      final other = others.isNotEmpty ? others.first : (participants.isNotEmpty ? participants.first : null);
      return ChatConversation(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        messages: const [],
        otherUserName: other?['name'],
        otherUserId: other?['id'],
        listingId: j['listingId']?.toString(),
        lastMessage: j['lastMessage'] as String?,
        updatedAt: j['updatedAt'] != null
            ? DateTime.tryParse(j['updatedAt'].toString())
            : null,
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
  Future<Result<ChatMessage>> sendMessage(String conversationId, String text,
      {bool isOffer = false, String? offerListingId, String? imageUrl}) async {
    final res = await _api.post('/conversations/$conversationId/messages', body: {
      'text': text,
      'isOffer': isOffer,
      'offerListingId': offerListingId,
      'imageUrl': imageUrl,
    });
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<ChatMessage>(res.failure);
    }
    final msg = _msgFromJson((res as ResultSuccess<Map<String, dynamic>>).data['data'] as Map<String, dynamic>);
    return ResultSuccess<ChatMessage>(msg);
  }

  /// Đánh dấu tất cả tin nhắn của người khác trong conversation là đã đọc.
  Future<Result<List<String>>> markRead(String conversationId) async {
    final res = await _api.post('/conversations/$conversationId/read');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<List<String>>(
          ((d['data']?['messageIds'] as List?) ?? []).map((e) => e.toString()).toList(),
        ),
      FailureResult(failure: final f) => FailureResult<List<String>>(f),
    };
  }

  // E4 — auto-create conversation (or get existing)
  Future<Result<String>> getOrCreateConversation(String otherUserId, {String? listingId}) async {
    final res = await _api.post('/conversations/init', body: {'otherUserId': otherUserId, 'listingId': listingId});
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<String>(res.failure);
    }
    final convId = (res as ResultSuccess<Map<String, dynamic>>).data['data']['_id'] as String;
    return ResultSuccess<String>(convId);
  }
}
