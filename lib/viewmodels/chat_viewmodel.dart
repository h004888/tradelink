import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final String conversationId;

  UiState<List<ChatMessage>> _state = const Loading();
  UiState<List<ChatMessage>> get state => _state;
  final List<ChatMessage> _messages = [];

  Timer? _timer;

  ChatViewModel({required this.conversationId}) { load(); }

  Future<void> load() async {
    final result = await _repository.getMessages(conversationId);
    switch (result) {
      case ResultSuccess(data: final msgs): _messages.addAll(msgs); _state = Success(List.from(_messages));
      case FailureResult(failure: final f): _state = Error(message: f.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    final result = await _repository.sendMessage(text);
    switch (result) {
      case ResultSuccess(data: final msg): _messages.add(msg); _state = Success(List.from(_messages));
      case FailureResult(failure: final f): _state = Error(message: f.message);
    }
    notifyListeners();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}
