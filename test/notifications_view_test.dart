import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/repositories/notification_repository.dart';
import 'package:tradelink/utils/constants.dart';
import 'package:tradelink/views/notifications/notifications_view.dart';

void main() {
  group('notificationRoute', () {
    test('prefers deeplink over type and relatedId routing', () {
      final notification = AppNotification(
        id: 'n1',
        type: NotificationType.offer,
        title: 'Offer accepted',
        body: 'Offer accepted',
        createdAt: DateTime.utc(2026, 7, 20),
        relatedId: 'offer1',
        entityType: 'transaction',
        entityId: 'tx1',
        deeplink: '${AppPaths.transactionSale}/tx1',
      );

      expect(
        notificationRoute(notification),
        '${AppPaths.transactionSale}/tx1',
      );
    });

    test('falls back to entity metadata before legacy relatedId', () {
      expect(
        notificationRoute(
          AppNotification(
            id: 'n2',
            type: NotificationType.chat,
            title: 'Chat',
            body: 'Chat',
            createdAt: DateTime.utc(2026, 7, 20),
            entityType: 'conversation',
            entityId: 'conv1',
          ),
        ),
        '${AppPaths.chat}/conv1',
      );

      expect(
        notificationRoute(
          AppNotification(
            id: 'n3',
            type: NotificationType.transaction,
            title: 'Transaction',
            body: 'Transaction',
            createdAt: DateTime.utc(2026, 7, 20),
            entityType: 'transaction',
            entityId: 'tx1',
          ),
        ),
        '${AppPaths.transactionSale}/tx1',
      );

      expect(
        notificationRoute(
          AppNotification(
            id: 'n4',
            type: NotificationType.wallet,
            title: 'Wallet',
            body: 'Wallet',
            createdAt: DateTime.utc(2026, 7, 20),
            entityType: 'wallet',
            entityId: 'wallet1',
          ),
        ),
        AppPaths.wallet,
      );
    });
  });
}
