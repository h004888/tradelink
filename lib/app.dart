import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'router.dart';
import 'utils/theme.dart';
import 'viewmodels/splash_viewmodel.dart';

class TradeLinkApp extends StatelessWidget {
  const TradeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
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
