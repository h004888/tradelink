import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/result.dart';
import '../repositories/notification_repository.dart';
import '../utils/constants.dart';
import 'notification_badge.dart';

/// Icon chuông thông báo — tự tải số lượng chưa đọc và hiện badge.
/// Tự refresh sau khi quay lại từ màn Thông báo (đã đọc bớt).
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _repo = NotificationRepository();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _repo.getUnreadCount();
    if (mounted && res is ResultSuccess<int>) {
      setState(() => _unreadCount = res.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            await context.push(AppPaths.notifications);
            _load();
          },
          visualDensity: VisualDensity.compact,
        ),
        NotificationBadge(count: _unreadCount),
      ],
    );
  }
}
