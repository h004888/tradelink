import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradelink/core/result.dart';
import 'package:tradelink/core/ui_state.dart';
import 'package:tradelink/repositories/notification_repository.dart';
import 'package:tradelink/viewmodels/notifications_viewmodel.dart';
import 'package:tradelink/widgets/notification_bell.dart';

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository({
    this.unreadCount = 0,
    this.notifications = const [],
  });

  final int unreadCount;
  final List<AppNotification> notifications;

  @override
  Future<Result<int>> getUnreadCount() async => ResultSuccess<int>(unreadCount);

  @override
  Future<Result<List<AppNotification>>> getAll() async =>
      ResultSuccess<List<AppNotification>>(notifications);
}

AppNotification _notification(String id, {bool isRead = false}) =>
    AppNotification(
      id: id,
      type: NotificationType.chat,
      title: id,
      body: id,
      isRead: isRead,
      createdAt: DateTime.utc(2026, 7, 20),
    );

void main() {
  testWidgets(
    'NotificationBell increments unread count on realtime notification',
    (tester) async {
      final controller = StreamController<AppNotification>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBell(
              repository: _FakeNotificationRepository(),
              notificationStream: controller.stream,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1'), findsNothing);
      controller.add(_notification('n1'));
      await tester.pump();
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    },
  );

  test(
    'NotificationsViewModel prepends realtime notification without duplicates',
    () async {
      final controller = StreamController<AppNotification>.broadcast();
      addTearDown(controller.close);
      final oldNotification = _notification('old');
      final newNotification = _notification('new');

      final vm = NotificationsViewModel(
        repository: _FakeNotificationRepository(
          notifications: [oldNotification],
        ),
        notificationStream: controller.stream,
      );
      addTearDown(vm.dispose);
      await Future<void>.delayed(Duration.zero);

      controller.add(newNotification);
      await Future<void>.delayed(Duration.zero);
      controller.add(newNotification);
      await Future<void>.delayed(Duration.zero);

      final state = vm.state as Success<List<AppNotification>>;
      expect(state.data.map((n) => n.id), ['new', 'old']);
    },
  );
}
