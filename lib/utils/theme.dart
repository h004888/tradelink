import 'package:flutter/material.dart';

/// Cấu hình theme tập trung cho toàn bộ app.
class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
