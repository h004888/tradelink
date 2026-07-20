import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/repositories/notification_repository.dart';

void main() {
  group('NotificationRepository parser', () {
    test('reads new contract fields and wallet type', () {
      final notification = NotificationRepository.parseForTest({
        '_id': 'n1',
        'type': 'wallet',
        'title': 'Vi',
        'body': 'Cong tien',
        'isRead': false,
        'createdAt': '2026-07-20T00:00:00Z',
        'relatedId': 'tx1',
        'entityType': 'transaction',
        'entityId': 'tx1',
        'action': 'wallet.credited',
        'deeplink': '/wallet',
      });

      expect(notification.type, NotificationType.wallet);
      expect(notification.entityType, 'transaction');
      expect(notification.entityId, 'tx1');
      expect(notification.action, 'wallet.credited');
      expect(notification.deeplink, '/wallet');
      expect(notification.relatedId, 'tx1');
    });

    test('keeps compatibility with old relatedId-only notification', () {
      final notification = NotificationRepository.parseForTest({
        '_id': 'n2',
        'type': 'chat',
        'relatedId': 'conv1',
      });

      expect(notification.type, NotificationType.chat);
      expect(notification.relatedId, 'conv1');
      expect(notification.entityId, isNull);
      expect(notification.deeplink, isNull);
    });
  });
}
