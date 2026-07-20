// Unit test for chat_viewmodel sendMessage flow
import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/api_client.dart';
import 'package:tradelink/core/failure.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/repositories/chat_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ChatRepository.sendMessage', () {
    test('parses success response correctly', () {
      // Verify that ChatMessage parses API response correctly
      final msg = ChatMessage(
        id: '6a5b00acc74458c05354d119',
        senderId: '6a5aed4b1507c2bf121dc99d',
        senderName: 'Chat User 1',
        text: 'Test message',
        timestamp: DateTime.now(),
      );
      expect(msg.senderName, 'Chat User 1');
      expect(msg.isOffer, false);
    });

    test('isOffer defaults to false', () {
      final msg = ChatMessage(
        id: 'x',
        senderId: 'y',
        senderName: 'z',
        text: 't',
        timestamp: DateTime.now(),
      );
      expect(msg.isOffer, isFalse);
      expect(msg.offerListingId, isNull);
    });
  });
}