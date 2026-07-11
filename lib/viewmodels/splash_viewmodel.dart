import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/result.dart';
import '../core/ui_state.dart';
import '../router.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SplashViewModel extends ChangeNotifier {
  UiState<void> _state = const Loading();
  UiState<void> get state => _state;

  bool _isMaintenanceMode = false;
  bool get isMaintenanceMode => _isMaintenanceMode;

  String? _maintenanceMessage;
  String? get maintenanceMessage => _maintenanceMessage;

  /// Deep link target được capture khi app launch
  String? _pendingDeepLink;
  String? get pendingDeepLink => _pendingDeepLink;

  /// Deep link từ push notification
  String? _notificationDeepLink;
  String? get notificationDeepLink => _notificationDeepLink;

  SplashViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Khôi phục token từ persistent storage
    await ApiClient.instance.init();

    // 2. Tải remote configuration (feature flags, URLs)
    await _fetchRemoteConfig();

    // 3. Kiểm tra maintenance mode
    await _checkMaintenance();

    // 4. Analytics
    AnalyticsService.instance.track('app_launched');

    _state = const Success(null);
    notifyListeners();
  }

  /// Capture deep link từ router state trước khi navigate
  void captureDeepLink(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri != '/' && uri != AppPaths.home && uri != AppPaths.onboarding) {
      _pendingDeepLink = uri;
    }
  }

  /// Nhận deep link từ push notification payload.
  /// Gọi từ notification handler (FCM) khi app đang mở hoặc vừa launch.
  ///
  /// Payload format: { "type": "new_message|listing_update|offer", "targetId": "..." }
  void setNotificationDeepLink(String type, String targetId) {
    final path = switch (type) {
      'new_message' || 'message' => '${AppPaths.chat}/$targetId',
      'listing_update' || 'listing' => '${AppPaths.itemDetail}/$targetId',
      'offer' => '${AppPaths.itemDetail}/$targetId',
      'transaction' => '${AppPaths.transactionSale}/$targetId',
      _ => null,
    };
    if (path != null) {
      _notificationDeepLink = path;
      AnalyticsService.instance.track('notification_opened', properties: {'type': type, 'targetId': targetId});
    }
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      // Gọi API lấy config — nếu fail vẫn tiếp tục được
      final res = await ApiClient.instance.get('/app/config');
      if (res is ResultSuccess<Map<String, dynamic>>) {
        final data = res.data['data'] as Map? ?? res.data;
        AnalyticsService.instance.track('remote_config_loaded', properties: {'keys': data.keys.length.toString()});
      }
    } catch (_) {
      // Silent fail — vẫn hoạt động với config mặc định
      debugPrint('[Splash] Remote config unavailable, using defaults');
    }
  }

  Future<void> _checkMaintenance() async {
    try {
      final res = await ApiClient.instance.get('/app/status');
      if (res is ResultSuccess<Map<String, dynamic>>) {
        final data = res.data['data'] as Map? ?? res.data;
        _isMaintenanceMode = data['maintenance'] == true;
        _maintenanceMessage = data['maintenanceMessage'] as String?;
      }
    } catch (_) {
      // Silent fail
    }
  }

  void navigateNext(BuildContext context) {
    if (_isMaintenanceMode) {
      // Nếu maintenance → hiển thị maintenance screen
      _state = Error(
        message: _maintenanceMessage ?? 'Hệ thống đang bảo trì. Vui lòng quay lại sau.',
        retryable: false,
      );
      notifyListeners();
      return;
    }

    // Capture deep link trước khi navigate
    captureDeepLink(context);

    final token = ApiClient.instance.getToken();
    if (token != null) {
      _navigateToDestination(context, isAuthenticated: true);
    } else {
      _checkOnboarding(context);
    }
  }

  void _navigateToDestination(BuildContext context, {bool isAuthenticated = false}) {
    // Ưu tiên 1: Deep link từ push notification
    if (_notificationDeepLink != null) {
      final target = _notificationDeepLink!;
      _notificationDeepLink = null;
      if (isAuthenticated || _isPublicPath(target)) {
        context.go(target);
        return;
      }
      // Notification target là protected → redirect login
      context.go('${AppPaths.login}?redirect=${Uri.encodeComponent(target)}');
      return;
    }
    // Ưu tiên 2: Deep link thông thường
    if (_pendingDeepLink != null) {
      final target = _pendingDeepLink!;
      _pendingDeepLink = null;
      if (isAuthenticated || _isPublicPath(target)) {
        context.go(target);
        return;
      }
    }
    context.go(AppPaths.home);
  }

  bool _isPublicPath(String location) {
    return AppRouter.isPublic(location);
  }

  Future<void> _checkOnboarding(BuildContext context) async {
    final onboardingDone = await StorageService.instance.isOnboardingDone();
    if (onboardingDone) {
      _navigateToDestination(context, isAuthenticated: false);
    } else {
      context.go(AppPaths.onboarding);
    }
  }
}
