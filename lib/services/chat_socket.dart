import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/api_client.dart';
import '../core/app_config.dart';
import '../repositories/chat_repository.dart';

/// Service kết nối socket.io tới backend chat realtime.
/// Thay thế polling 5s bằng push event.
class ChatSocket {
  static ChatSocket? _instance;
  static ChatSocket get instance => _instance ??= ChatSocket._();
  ChatSocket._();

  IO.Socket? _socket;
  final Map<String, StreamController<ChatMessage>> _controllers = {};

  /// Mở socket nếu chưa có (idempotent). Tự reconnect khi mất kết nối.
  void connect() {
    if (_socket != null) return;
    final token = ApiClient.instance.getToken();
    if (token == null) return;
    // Strip /api/v1 suffix — socket.io connects to server root, not API path
    final baseUrl = AppConfig.baseUrl.replaceFirst('/api/v1', '');
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          // Cho phép cả websocket và polling — Android emulator thường cần polling fallback
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          // Tăng timeout để Android emulator có đủ thời gian connect
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );
    _socket!.onConnect((_) {
      debugPrint('[ChatSocket] connected');
      // re-join tất cả conversations đang theo dõi
      for (final cid in _controllers.keys) {
        _socket!.emit('join', cid);
      }
    });
    _socket!.onDisconnect((reason) {
      debugPrint('[ChatSocket] disconnected: $reason');
    });
    _socket!.onConnectError((err) {
      debugPrint('[ChatSocket] connect_error: $err');
    });
    _socket!.onError((err) {
      debugPrint('[ChatSocket] error: $err');
    });
    _socket!.on('message:new', (data) {
      debugPrint('[ChatSocket] message:new received');
      if (data is! Map) return;
      final convId = data['conversationId']?.toString();
      if (convId == null) return;
      final ctl = _controllers[convId];
      if (ctl == null || ctl.isClosed) return;
      ctl.add(_parse(data));
    });
    _socket!.connect();
  }

  /// Theo dõi 1 conversation — trả về stream phát ra mỗi khi có message mới
  /// (kể cả từ người khác gửi).
  Stream<ChatMessage> watch(String conversationId) {
    connect();
    final ctl = _controllers.putIfAbsent(
      conversationId,
      () => StreamController<ChatMessage>.broadcast(),
    );
    // join room trên socket
    _socket?.emit('join', conversationId);
    return ctl.stream;
  }

  /// Gửi message realtime qua socket (kèm `sendAsOffer` flag).
  /// Trả về Future<void> khi ack từ server.
  Future<bool> sendRealtime(String conversationId, String text,
      {bool isOffer = false, String? offerListingId}) async {
    connect();
    final s = _socket;
    if (s == null) return false;
    final completer = Completer<bool>();
    s.emitWithAck(
      'send',
      {
        'conversationId': conversationId,
        'text': text,
        'isOffer': isOffer,
        'offerListingId': offerListingId,
      },
      ack: (ack) {
        final ok = ack is Map && ack['success'] == true;
        if (!completer.isCompleted) completer.complete(ok);
      },
    );
    return completer.future.timeout(const Duration(seconds: 5), onTimeout: () => false);
  }

  void dispose() {
    for (var c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
    _socket?.dispose();
    _socket = null;
    _instance = null;
  }

  ChatMessage _parse(Map d) => ChatMessage(
        id: d['_id']?.toString() ?? '',
        senderId: d['senderId']?.toString() ?? '',
        senderName: d['senderName']?.toString() ?? '',
        text: d['text']?.toString() ?? '',
        timestamp: DateTime.tryParse(d['createdAt']?.toString() ?? '') ?? DateTime.now(),
        isOffer: d['isOffer'] == true,
        offerListingId: d['offerListingId']?.toString(),
      );
}
