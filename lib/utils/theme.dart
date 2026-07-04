import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────
// Color Tokens — từ DESIGN.md
// ──────────────────────────────────────────────

class TradeLinkColors {
  TradeLinkColors._();

  // Surface scale
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBD5F5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color surfaceTint = Color(0xFF455F88);

  // Primary — Sale side (Deep Blue)
  static const Color primary = Color(0xFF002045);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A365D);
  static const Color onPrimaryContainer = Color(0xFF86A0CD);
  static const Color inversePrimary = Color(0xFFADC7F7);
  static const Color primaryFixed = Color(0xFFD6E3FF);
  static const Color primaryFixedDim = Color(0xFFADC7F7);
  static const Color onPrimaryFixed = Color(0xFF001B3C);
  static const Color onPrimaryFixedVariant = Color(0xFF2D476F);

  // Secondary — Trade side (Teal/Emerald)
  static const Color secondary = Color(0xFF1B6B51);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFA6F2D1);
  static const Color onSecondaryContainer = Color(0xFF237157);
  static const Color secondaryFixed = Color(0xFFA6F2D1);
  static const Color secondaryFixedDim = Color(0xFF8BD6B6);
  static const Color onSecondaryFixed = Color(0xFF002116);
  static const Color onSecondaryFixedVariant = Color(0xFF00513B);

  // Tertiary — Action/Info
  static const Color tertiary = Color(0xFF002336);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF003A55);
  static const Color onTertiaryContainer = Color(0xFF1BA9ED);
  static const Color tertiaryFixed = Color(0xFFC9E6FF);
  static const Color tertiaryFixedDim = Color(0xFF89CEFF);
  static const Color onTertiaryFixed = Color(0xFF001E2F);
  static const Color onTertiaryFixedVariant = Color(0xFF004C6E);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Functional semantic colors
  static const Color saleBlue = Color(0xFF1A365D);
  static const Color tradeTeal = Color(0xFF065F46);
  static const Color actionBlue = Color(0xFF0EA5E9);
  static const Color disputeRed = Color(0xFFBA1A1A);
  static const Color escrowAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF16A34A);

  // Component-specific
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardDivider = Color(0xFFF1F5F9);
  static const Color inputBorder = Color(0xFFCBD5E1);
}

// ──────────────────────────────────────────────
// Typography — Inter font family
// ──────────────────────────────────────────────

class TradeLinkTypography {
  TradeLinkTypography._();

  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 36, fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 36, color: colorScheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28, fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 28, color: colorScheme.onSurface,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 18, fontWeight: FontWeight.w400, color: colorScheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w400, color: colorScheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Spacing — 8px linear scale
// ──────────────────────────────────────────────

class TradeLinkSpacing {
  TradeLinkSpacing._();
  static const double base = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 48;
  static const double containerMax = 1280;
  static const double tight = 12;
}

// ──────────────────────────────────────────────
// Border Radius
// ──────────────────────────────────────────────

class TradeLinkRadii {
  TradeLinkRadii._();
  static const double sm = 2;
  static const double base = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double full = 9999;
}

// ──────────────────────────────────────────────
// ThemeData
// ──────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ColorScheme _buildColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: TradeLinkColors.primary,
      onPrimary: TradeLinkColors.onPrimary,
      primaryContainer: TradeLinkColors.primaryContainer,
      onPrimaryContainer: TradeLinkColors.onPrimaryContainer,
      secondary: TradeLinkColors.secondary,
      onSecondary: TradeLinkColors.onSecondary,
      secondaryContainer: TradeLinkColors.secondaryContainer,
      onSecondaryContainer: TradeLinkColors.onSecondaryContainer,
      tertiary: TradeLinkColors.tertiary,
      onTertiary: TradeLinkColors.onTertiary,
      tertiaryContainer: TradeLinkColors.tertiaryContainer,
      onTertiaryContainer: TradeLinkColors.onTertiaryContainer,
      error: TradeLinkColors.error,
      onError: TradeLinkColors.onError,
      errorContainer: TradeLinkColors.errorContainer,
      onErrorContainer: TradeLinkColors.onErrorContainer,
      surface: TradeLinkColors.surface,
      onSurface: TradeLinkColors.onSurface,
      surfaceContainerHighest: TradeLinkColors.surfaceContainerHighest,
      surfaceContainerHigh: TradeLinkColors.surfaceContainerHigh,
      surfaceContainer: TradeLinkColors.surfaceContainer,
      surfaceContainerLow: TradeLinkColors.surfaceContainerLow,
      surfaceContainerLowest: TradeLinkColors.surfaceContainerLowest,
      surfaceDim: TradeLinkColors.surfaceDim,
      surfaceBright: TradeLinkColors.surfaceBright,
      onSurfaceVariant: TradeLinkColors.onSurfaceVariant,
      outline: TradeLinkColors.outline,
      outlineVariant: TradeLinkColors.outlineVariant,
      inverseSurface: TradeLinkColors.inverseSurface,
      inversePrimary: TradeLinkColors.inversePrimary,
      onInverseSurface: TradeLinkColors.inverseOnSurface,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _buildColorScheme(),
    textTheme: TradeLinkTypography.buildTextTheme(_buildColorScheme()),
    scaffoldBackgroundColor: TradeLinkColors.surface,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: TradeLinkColors.surfaceContainerLow,
      foregroundColor: TradeLinkColors.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: TradeLinkColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
        side: const BorderSide(color: TradeLinkColors.cardBorder, width: 1),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: TradeLinkSpacing.marginMobile,
        vertical: TradeLinkSpacing.base,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TradeLinkColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TradeLinkSpacing.md, vertical: TradeLinkSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        borderSide: const BorderSide(color: TradeLinkColors.inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        borderSide: const BorderSide(color: TradeLinkColors.inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        borderSide: const BorderSide(color: TradeLinkColors.actionBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        borderSide: const BorderSide(color: TradeLinkColors.error, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TradeLinkColors.primaryContainer,
        foregroundColor: TradeLinkColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.lg, vertical: TradeLinkSpacing.md,
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TradeLinkColors.primaryContainer,
        side: const BorderSide(color: TradeLinkColors.primaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TradeLinkRadii.base),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.lg, vertical: TradeLinkSpacing.md,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TradeLinkColors.primaryContainer,
      foregroundColor: TradeLinkColors.onPrimary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: TradeLinkColors.surfaceContainerLow,
      labelStyle: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: TradeLinkColors.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.full),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: TradeLinkColors.cardDivider, thickness: 1, space: 1,
    ),
  );
}
