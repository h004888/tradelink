import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/home_viewmodel.dart';
import 'views/home/home_view.dart';
import 'utils/theme.dart';

class TradeLinkApp extends StatelessWidget {
  const TradeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'TradeLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeView(),
      ),
    );
  }
}
