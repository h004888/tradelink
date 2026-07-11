import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'router.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ApiClient.instance.init();

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
