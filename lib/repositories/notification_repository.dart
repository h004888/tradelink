import '../core/api_client.dart';
import '../core/result.dart';

enum NotificationType { transaction, chat, dispute, system, offer, wallet }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;
  final String? entityType;
  final String? entityId;
  final String? action;
  final String? deeplink;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
    this.entityType,
    this.entityId,
    this.action,
    this.deeplink,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    relatedId: relatedId,
    entityType: entityType,
    entityId: entityId,
    action: action,
    deeplink: deeplink,
  );
}

class NotificationRepository {
  final _api = ApiClient.instance;

  static AppNotification parseForTest(Map<String, dynamic> j) => _fromJson(j);

  static AppNotification _fromJson(Map<String, dynamic> j) {
    final t = j['type'] as String?;
    final type = switch (t) {
      'transaction' => NotificationType.transaction,
      'chat' => NotificationType.chat,
      'dispute' => NotificationType.dispute,
      'offer' => NotificationType.offer,
      'wallet' => NotificationType.wallet,
      _ => NotificationType.system,
    };
    return AppNotification(
      id: j['_id'] as String? ?? j['id'] as String? ?? '',
      type: type,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      isRead: j['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      relatedId: j['relatedId']?.toString(),
      entityType: j['entityType']?.toString(),
      entityId: j['entityId']?.toString(),
      action: j['action']?.toString(),
      deeplink: j['deeplink']?.toString(),
    );
  }

  // F2 — list notifications
  Future<Result<List<AppNotification>>> getAll() async {
    final res = await _api.get('/notifications');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<List<AppNotification>>(res.failure);
    }
    final data =
        (res as ResultSuccess<Map<String, dynamic>>).data['data'] as List?;
    final list = (data ?? [])
        .map((n) => _fromJson(n as Map<String, dynamic>))
        .toList();
    return ResultSuccess<List<AppNotification>>(list);
  }

  // F3 — mark as read
  Future<Result<bool>> markRead(String id) async {
    final res = await _api.patch('/notifications/$id/read');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<bool>(res.failure);
    }
    return ResultSuccess<bool>(true);
  }

  // F4 — mark all as read
  Future<Result<bool>> markAllRead() async {
    final res = await _api.patch('/notifications/read-all');
    if (res is FailureResult<Map<String, dynamic>>) {
      return FailureResult<bool>(res.failure);
    }
    return ResultSuccess<bool>(true);
  }

  Future<Result<int>> getUnreadCount() async {
    final res = await _api.get('/notifications/unread-count');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<int>(
        (d['data']?['count'] as num?)?.toInt() ?? 0,
      ),
      FailureResult(failure: final f) => FailureResult<int>(f),
    };
  }
}
