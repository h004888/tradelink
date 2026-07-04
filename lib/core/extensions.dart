import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  double get screenWidth => mediaQuerySize.width;
  double get screenHeight => mediaQuerySize.height;
}

extension StringHardcoded on String {
  /// Marker for strings that need i18n keys.
  /// Replace `.hardcoded` with `tr()` when keys are ready.
  String get hardcoded => this;
}
