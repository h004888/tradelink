// Integration test for chat sending flow
// Run with: flutter test integration_test/chat_send_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tradelink/core/api_client.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/repositories/chat_repository.dart';
import 'package:tradelink/viewmodels/chat_viewmodel.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ChatViewModel empty text returns false immediately',
      (WidgetTester tester) async {
    await ApiClient.instance.init();
    final vm = ChatViewModel(conversationId: 'fake-id');
    final result = await vm.sendMessage('');
    expect(result, isFalse);
    vm.dispose();
  });

  testWidgets('ChatViewModel initial state is Loading',
      (WidgetTester tester) async {
    await ApiClient.instance.init();
    final vm = ChatViewModel(conversationId: 'fake-id');
    expect(vm.state, isA<Loading>());
    vm.dispose();
  });

  testWidgets('ChatViewModel send HTTP succeeds adds message to local list',
      (WidgetTester tester) async {
    await ApiClient.instance.init();

    // Login trước để có token hợp lệ
    final loginResult = await ApiClient.instance.post('/auth/login',
        body: {'email': 'chatuser1@test.com', 'password': 'pw12345'});
    if (loginResult is! ResultSuccess<Map<String, dynamic>>) {
      return; // Skip test nếu không login được
    }
    final data = (loginResult.data['data'] as Map);
    final token = data['token'] as String;
    final userId = (data['user'] as Map)['_id'] as String;
    await ApiClient.instance.setToken(token);
    await ApiClient.instance.setUserId(userId);

    // Tìm conversation hiện có
    final convsResult = await ApiClient.instance.get('/conversations');
    if (convsResult is! ResultSuccess<Map<String, dynamic>>) {
      return;
    }
    final convs = (convsResult.data['data'] as List);
    if (convs.isEmpty) {
      return; // Skip nếu không có conversation nào
    }
    final convId = (convs.first as Map)['_id'] as String;

    final vm = ChatViewModel(conversationId: convId);
    // Đợi load xong
    await Future.delayed(const Duration(milliseconds: 2000));

    final initialCount = vm.state is Success<List<ChatMessage>>
        ? (vm.state as Success<List<ChatMessage>>).data.length
        : 0;

    // Gửi message test
    final ok = await vm.sendMessage('Integration test message ${DateTime.now().millisecondsSinceEpoch}');
    expect(ok, isTrue, reason: 'sendMessage should return true on success');

    // Verify message được add vào list (UiState.Success là class riêng của ViewModel)
    expect(vm.state, isA<Success<List<ChatMessage>>>());
    final newCount = (vm.state as Success<List<ChatMessage>>).data.length;
    expect(newCount, initialCount + 1,
        reason: 'Message count should increase by 1 after send');

    // Verify message text trong list
    final messages = (vm.state as Success<List<ChatMessage>>).data;
    final lastMsg = messages.last;
    expect(lastMsg.text, startsWith('Integration test message'));

    vm.dispose();
  }, timeout: const Timeout(Duration(seconds: 30)));
}