import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/api_client.dart';
import 'core/result.dart';
import 'repositories/auth_repository.dart';
import 'router.dart';
import 'utils/theme.dart';
import 'viewmodels/splash_viewmodel.dart';

class TradeLinkApp extends StatelessWidget {
  const TradeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire refresh token callback globally — khi API trả 401, ApiClient tự gọi refresh
    final authRepo = AuthRepository();
    ApiClient.instance.registerRefreshCallback(() async {
      final r = await authRepo.refreshToken();
      return r is ResultSuccess<bool>;
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'TradeLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
      ),
    );
  }
}
