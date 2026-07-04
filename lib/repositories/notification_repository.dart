import '../../core/result.dart';

enum NotificationType { transaction, chat, dispute, system }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const AppNotification({
    required this.id, required this.type, required this.title,
    required this.body, this.isRead = false, required this.createdAt, this.relatedId,
  });
}

class NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(id: 'n1', type: NotificationType.transaction, title: 'Giao dịch mới', body: 'Trần Văn B đã gửi đề nghị mua Sony A7IV', createdAt: DateTime.now().subtract(const Duration(hours: 2)), relatedId: 'tx-001'),
    AppNotification(id: 'n2', type: NotificationType.chat, title: 'Tin nhắn mới', body: 'Người bán đã trả lời tin nhắn của bạn', createdAt: DateTime.now().subtract(const Duration(hours: 5)), isRead: true, relatedId: 'conv-1'),
    AppNotification(id: 'n3', type: NotificationType.system, title: 'Chào mừng!', body: 'Chào mừng bạn đến với TradeLink. Hãy khám phá ngay!', createdAt: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
  ];

  Future<Result<List<AppNotification>>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ResultSuccess(_notifications);
  }
}
