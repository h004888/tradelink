import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'core/result.dart';
import 'router.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ApiClient.instance.init();

  // Backfill role cho phiên đăng nhập từ trước khi có tính năng phân luồng admin
  // (có token nhưng chưa từng cache role) — cần biết role NGAY trước khi router
  // dựng route đầu tiên, nên chờ ở đây thay vì làm async sau khi app đã chạy.
  if (ApiClient.instance.getToken() != null && ApiClient.instance.getRole() == null) {
    try {
      final res = await ApiClient.instance.get('/auth/me');
      if (res is ResultSuccess<Map<String, dynamic>>) {
        final role = (res.data['data'] as Map?)?['role'] as String?;
        if (role != null) await ApiClient.instance.setRole(role);
      }
    } catch (_) {
      // Silent fail — nếu không lấy được role, router coi như user thường
    }
  }

  // Kiểm tra onboarding state ngay khi khởi động
  AppRouter.onboardingDone = await StorageService.instance.isOnboardingDone();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      child: const TradeLinkApp(),
    ),
  );
}
