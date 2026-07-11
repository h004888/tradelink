import 'dart:async';
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

  StreamSubscription<ChatMessage>? _socketSub;

  ChatViewModel({required this.conversationId, this.offerListingId}) {
    load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _socketSub?.cancel();
    _socketSub = _socket.watch(conversationId).listen((msg) {
      // Bỏ qua duplicate (khi mình tự gửi, server cũng broadcast về mình)
      final exists = _messages.any((m) => m.id == msg.id && msg.id.isNotEmpty);
      if (exists) return;
      _messages.add(msg);
      _state = Success(List.from(_messages));
      notifyListeners();
    });
  }

  void toggleSendAsOffer() {
    if (offerListingId == null) return;
    _sendAsOffer = !_sendAsOffer;
    notifyListeners();
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final result = await _repository.getMessages(conversationId);
    if (result is ResultSuccess<List<ChatMessage>>) {
      _messages
        ..clear()
        ..addAll(result.data);
      _state = Success(List.from(_messages));
    } else if (result is FailureResult<List<ChatMessage>>) {
      _state = Error(message: result.failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<bool> sendMessage(String text) async {
    if (text.isEmpty) return false;
    // Thử gửi qua socket realtime trước
    final ok = await _socket.sendRealtime(
      conversationId,
      text,
      isOffer: _sendAsOffer,
      offerListingId: _sendAsOffer ? offerListingId : null,
    );
    if (ok) {
      _sendAsOffer = false;
      notifyListeners();
      return true;
    }
    // Fallback HTTP nếu socket lỗi
    final result = await _repository.sendMessage(
      conversationId,
      text,
      isOffer: _sendAsOffer,
      offerListingId: _sendAsOffer ? offerListingId : null,
    );
    if (result is ResultSuccess<ChatMessage>) {
      final exists = _messages.any((m) => m.id == result.data.id && result.data.id.isNotEmpty);
      if (!exists) _messages.add(result.data);
      _state = Success(List.from(_messages));
      _sendAsOffer = false;
    } else if (result is FailureResult<ChatMessage>) {
      _state = Error(message: result.failure.message, retryable: true);
    }
    notifyListeners();
    return result is ResultSuccess<ChatMessage>;
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }
}
