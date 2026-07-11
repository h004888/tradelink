import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/chat_repository.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  UiState<List<ChatConversation>> _state = const Loading();
  UiState<List<ChatConversation>> get state => _state;

  ChatListViewModel() { load(); }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    final result = await _repository.getConversations();
    _state = switch (result) {
      ResultSuccess(data: final data) => Success(data),
      FailureResult(failure: final f) => Error(message: f.message, retryable: true),
    };
    notifyListeners();
  }
}
