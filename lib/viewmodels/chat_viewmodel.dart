import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/chat_repository.dart';
import '../../services/chat_socket.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final ChatSocket _socket = ChatSocket.instance;
  final String conversationId;
  final String? offerListingId;

  UiState<List<ChatMessage>> _state = const Loading();
  UiState<List<ChatMessage>> get state => _state;
  final List<ChatMessage> _messages = [];

  bool _sendAsOffer = false;
  bool get sendAsOffer => _sendAsOffer;

  /// Trạng thái gửi: đang gửi / lỗi
  UiState<void> _sendState = const Idle();
  UiState<void> get sendState => _sendState;

  StreamSubscription<ChatMessage>? _socketSub;
  bool _disposed = false;

  ChatViewModel({required this.conversationId, this.offerListingId}) {
    load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _socketSub?.cancel();
    _socketSub = _socket.watch(conversationId).listen((msg) {
      if (_disposed) return;
      // Dedup theo id (server broadcast về cả sender)
      final exists = _messages.any((m) => m.id == msg.id && msg.id.isNotEmpty);
      if (exists) return;
      _messages.add(msg);
      _state = Success(List.from(_messages));
      notifyListeners();
    });
  }

  void toggleSendAsOffer() {
    if (offerListingId == null || _disposed) return;
    _sendAsOffer = !_sendAsOffer;
    notifyListeners();
  }

  Future<void> load() async {
    _state = const Loading();
    if (!_disposed) notifyListeners();
    final result = await _repository.getMessages(conversationId);
    if (_disposed) return;
    if (result is ResultSuccess<List<ChatMessage>>) {
      _messages
        ..clear()
        ..addAll(result.data);
      _state = Success(List.from(_messages));
    } else if (result is FailureResult<List<ChatMessage>>) {
      _state = Error(message: result.failure.message, retryable: true);
    }
    if (!_disposed) notifyListeners();
  }

  /// Gửi message — HTTP là primary path (reliable), socket là bonus để broadcast nhanh hơn.
  /// Sau khi HTTP trả về 201, message được thêm vào local list NGAY để UX mượt.
  Future<bool> sendMessage(String text) async {
    if (text.isEmpty) return false;
    final isOffer = _sendAsOffer;
    final offerId = isOffer ? offerListingId : null;

    _sendState = const Loading();
    if (!_disposed) notifyListeners();

    // Gọi HTTP POST /conversations/:id/messages (luôn dùng — đảm bảo message được lưu)
    final result = await _repository.sendMessage(
      conversationId,
      text,
      isOffer: isOffer,
      offerListingId: offerId,
    );

    if (_disposed) return false;

    if (result is ResultSuccess<ChatMessage>) {
      // Thêm vào local list NGAY (dedup theo id)
      final msg = result.data;
      final exists = _messages.any((m) => m.id == msg.id && msg.id.isNotEmpty);
      if (!exists) {
        _messages.add(msg);
        _state = Success(List.from(_messages));
      }
      _sendAsOffer = false;
      _sendState = const Success(null);
      notifyListeners();
      debugPrint('[ChatViewModel] sent OK: ${msg.id}');
      return true;
    }

    // HTTP fail — set error state để UI hiển thị
    final failure = (result as FailureResult<ChatMessage>).failure;
    debugPrint('[ChatViewModel] send FAIL: ${failure.message}');
    _sendState = Error(message: failure.message, retryable: true);
    _state = Error(message: failure.message, retryable: true);
    if (!_disposed) notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    _socketSub?.cancel();
    super.dispose();
  }
}
