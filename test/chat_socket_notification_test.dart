import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/repositories/notification_repository.dart';
import 'package:tradelink/services/chat_socket.dart';

void main() {
  test(
    'ChatSocket emits notification:new payload as AppNotification',
    () async {
      final socket = ChatSocket.instance;
      addTearDown(socket.dispose);

      final events = <AppNotification>[];
      final sub = socket.watchNotifications().listen(events.add);
      addTearDown(sub.cancel);

      socket.emitNotificationForTest({
        '_id': 'n1',
        'type': 'wallet',
        'title': 'Wallet',
        'body': 'Credited',
        'isRead': false,
        'createdAt': '2026-07-20T00:00:00Z',
        'entityType': 'transaction',
        'entityId': 'tx1',
      });
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single.id, 'n1');
      expect(events.single.type, NotificationType.wallet);
      expect(events.single.entityType, 'transaction');
      expect(events.single.entityId, 'tx1');
    },
  );
}
