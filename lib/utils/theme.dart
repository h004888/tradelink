
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────
// Color Tokens — từ DESIGN.md (v alpha)
// ──────────────────────────────────────────────

class TradeLinkColors {
  TradeLinkColors._();

  // ── Brand colors (DESIGN.md: #232-234) ──
  static const Color primary = Color(0xFF2563EB);         // Protection Blue
  static const Color primaryHover = Color(0xFF1D4ED8);    // Primary Hover
  static const Color trustTeal = Color(0xFF14B8A6);        // Trust Teal
  static const Color paymentHeld = Color(0xFF0F766E);      // Payment Held

  // ── Semantic colors (DESIGN.md: #238-243) ──
  static const Color success = Color(0xFF16A34A);          // Success
  static const Color warning = Color(0xFFF59E0B);          // Warning
  static const Color error = Color(0xFFDC2626);            // Error
  static const Color info = Color(0xFF0284C7);             // Info
  static const Color neutral = Color(0xFFCBD5E1);          // Neutral

  // ── Neutral surfaces (DESIGN.md: #247-253) ──
  static const Color dark = Color(0xFF0F172A);             // Dark / text-primary
  static const Color darkSurface = Color(0xFF172033);      // Dark Surface
  static const Color surface = Color(0xFFFFFFFF);           // Surface (card/modal)
  static const Color background = Color(0xFFF8FAFC);        // Background
  static const Color textPrimary = Color(0xFF0F172A);      // Text Primary
  static const Color textSecondary = Color(0xFF64748B);    // Text Secondary
  static const Color textMuted = Color(0xFF94A3B8);        // Text Muted
  static const Color textOnDark = Color(0xFFF8FAFC);       // Text on Dark
  static const Color borderSubtle = Color(0xFFE2E8F0);     // Border subtle

  // ── Aliases để tương thích code cũ (DEPRECATED — dùng tên DESIGN.md) ──
  static const Color onSurface = dark;
  static const Color onSurfaceVariant = textSecondary;
  static const Color onPrimary = surface;
  static const Color onSecondary = surface;
  static const Color onError = surface;
  static const Color cardBorder = borderSubtle;
  static const Color cardDivider = Color(0xFFF1F5F9);
  static const Color inputBorder = neutral;
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color surfaceContainerLowest = surface;
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);
  static const Color surfaceDim = Color(0xFFE2E8F0);
  static const Color surfaceBright = surface;

  // ── Container variants ──
  static const Color primaryContainer = primary;
  static const Color secondaryContainer = trustTeal;
  static const Color errorContainer = Color(0x1ADC2626);
  static const Color tertiaryContainer = info;
  static const Color onPrimaryContainer = surface;
  static const Color onSecondaryContainer = surface;
  static const Color onErrorContainer = surface;
  static const Color onTertiaryContainer = surface;

  // ── M3 required ──
  static const Color secondary = trustTeal;
  static const Color tertiary = info;
  static const Color onTertiary = surface;
  static const Color inverseSurface = darkSurface;
  static const Color inversePrimary = Color(0xFF93BBFF);
  static const Color onInverseSurface = textOnDark;
  static const Color surfaceTint = primary;

  // ── Gradient helpers ──
  static const Color saleBlue = primary;
  static const Color tradeTeal = trustTeal;
  static const Color actionBlue = info;
  static const Color disputeRed = error;
  static const Color escrowAmber = warning;
  static const Color successGreen = success;
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
      // ── Hero money display — tabular-nums bắt buộc cho financial ledger ──
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 32, color: colorScheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 28, color: colorScheme.onSurface,
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

  // ── Money text — áp dụng tabular-nums cho mọi số tiền (DESIGN.md line 136) ──
  static const List<FontFeature> _tabularNums = [FontFeature.tabularFigures()];

  /// Standard money display — DESIGN.md price token (20px/700)
  static TextStyle money({Color color = TradeLinkColors.primary}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.01 * 20,
      fontFeatures: _tabularNums,
      height: 1.3,
    );
  }

  /// Hero money display — 28px/700 (cho detail/escrow)
  static TextStyle moneyLarge({Color color = TradeLinkColors.primary}) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.015 * 28,
      fontFeatures: _tabularNums,
      height: 1.2,
    );
  }

  /// Compact money display — 16px/600 (cho list item)
  static TextStyle moneyCompact({Color color = TradeLinkColors.primary}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      fontFeatures: _tabularNums,
      height: 1.3,
    );
  }
}

// ──────────────────────────────────────────────
// Text helper — bọc money Text an toàn với tabular-nums
// ──────────────────────────────────────────────

/// Helper để render số tiền với tabular-nums bắt buộc.
/// Dùng: TradeLinkText.money('1.500.000 đ', color: saleBlue)
class TradeLinkText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TradeLinkText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Render số tiền với tabular-nums (DESIGN.md yêu cầu cho mọi giá trị tiền tệ).
  /// size: 'compact' (16px), 'base' (20px, default), 'large' (28px)
  static Widget money(
    String amount, {
    Key? key,
    Color color = TradeLinkColors.primary,
    String size = 'base',
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final style = switch (size) {
      'compact' => TradeLinkTypography.moneyCompact(color: color),
      'large' => TradeLinkTypography.moneyLarge(color: color),
      _ => TradeLinkTypography.money(color: color),
    };
    return Text(
      amount,
      key: key,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
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
  static const double huge = 64;
  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 48;
  static const double containerMax = 1280;
  static const double tight = 12;
}

// ──────────────────────────────────────────────
// Shadows — DESIGN.md #310-321
// ──────────────────────────────────────────────

/// Soft, highly diffused shadows theo DESIGN.md.
class TradeLinkShadow {
  TradeLinkShadow._();

  /// Small — chip, input, card compact
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D0F172A), // rgba(15, 23, 42, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Medium — card default, bottom sheet, dropdown
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x140F172A), // rgba(15, 23, 42, 0.08)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Large — modal, panel nổi
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1F0F172A), // rgba(15, 23, 42, 0.12)
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Legacy — deprecated (giữ tương thích)
  static const List<BoxShadow> surface2 = large;
  static const List<BoxShadow> subtle = small;
}

// ──────────────────────────────────────────────
// Border Radius — DESIGN.md #324-339
// ──────────────────────────────────────────────

class TradeLinkRadii {
  TradeLinkRadii._();
  static const double xs = 4;     // DESIGN.md: xs = 4px
  static const double sm = 8;     // DESIGN.md: sm = 8px (chip, thumbnail)
  static const double md = 12;    // DESIGN.md: md = 12px (input, card compact)
  static const double lg = 16;    // DESIGN.md: lg = 16px (card, bottom sheet)
  static const double xl = 20;    // DESIGN.md: xl = 20px (elevated card, modal)
  static const double full = 9999; // Pill
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
      onInverseSurface: TradeLinkColors.onInverseSurface,
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
        borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
        borderSide: const BorderSide(color: TradeLinkColors.inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
        borderSide: const BorderSide(color: TradeLinkColors.inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
        borderSide: const BorderSide(color: TradeLinkColors.actionBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
        borderSide: const BorderSide(color: TradeLinkColors.error, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TradeLinkColors.primaryContainer,
        foregroundColor: TradeLinkColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
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
          borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
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
