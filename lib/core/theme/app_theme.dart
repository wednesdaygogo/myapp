import 'package:flutter/material.dart';

/// Minimalist Material 3 Light Theme
///
/// Design tokens based on minimalist principles:
/// - Primary: Subtle Blue (#007AFF) - calm, professional
/// - Background: Light Gray (#F5F5F7) - soft, neutral
/// - Surface: Pure White (#FFFFFF) - clean, minimal
/// - Cards: 12dp rounded corners with subtle borders
/// - Flat design with minimal shadows
class AppTheme {
  AppTheme._();

  // ============================================
  // CORE COLOR TOKENS
  // ============================================

  /// Primary brand color - Subtle blue accent
  static const Color primaryColor = Color(0xFF007AFF);

  /// Primary variant for emphasis states
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF005BB5);

  /// Background colors
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFEFF4);

  /// Text colors
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF86868B);
  static const Color textTertiary = Color(0xFFD2D2D7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Border and divider colors
  static const Color borderColor = Color(0xFFE5E5EA);
  static const Color dividerColor = Color(0xFFE5E5EA);

  // ============================================
  // SEMANTIC STATUS COLORS
  // ============================================

  /// Success - for positive trends, confirmations (soft green)
  static const Color successColor = Color(0xFF34C759);
  static const Color successLight = Color(0xFF7ED957);
  static const Color successDark = Color(0xFF28A745);

  /// Warning - for alerts, caution states (soft amber)
  static const Color warningColor = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFB340);
  static const Color warningDark = Color(0xFFE68A00);

  /// Error - for errors, negative trends, destructive actions (soft red)
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFF6B61);
  static const Color errorDark = Color(0xFFE6352B);

  /// Info - for informational states (soft blue)
  static const Color infoColor = Color(0xFF007AFF);
  static const Color infoLight = Color(0xFF4DA3FF);
  static const Color infoDark = Color(0xFF005BB5);

  // ============================================
  // SPACING SCALE
  // ============================================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ============================================
  // BORDER RADIUS
  // ============================================

  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // ELEVATION & SHADOWS
  // ============================================

  /// Minimal shadows - flat design approach
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 2,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ============================================
  // MATERIAL 3 LIGHT THEME
  // ============================================

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          onPrimary: textOnPrimary,
          primaryContainer: primaryLight,
          onPrimaryContainer: primaryDark,
          secondary: textSecondary,
          onSecondary: Colors.white,
          secondaryContainer: surfaceVariant,
          onSecondaryContainer: textPrimary,
          tertiary: infoColor,
          onTertiary: Colors.white,
          surface: surfaceColor,
          onSurface: textPrimary,
          surfaceContainerHighest: surfaceVariant,
          error: errorColor,
          onError: Colors.white,
          errorContainer: errorLight,
          onErrorContainer: errorDark,
          outline: borderColor,
          outlineVariant: dividerColor,
        ),

        // Scaffold
        scaffoldBackgroundColor: backgroundColor,

        // App Bar Theme - minimal, no shadow
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: _textTheme.titleLarge?.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Card Theme - minimal borders, no shadows
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
            side: const BorderSide(color: borderColor, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // Elevated Button Theme - subtle, minimal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: textOnPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            textStyle:
                _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),

        // Outlined Button Theme - preferred for actions
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            side: const BorderSide(color: borderColor, width: 1),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            textStyle:
                _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingMd,
              vertical: spacingSm,
            ),
            textStyle:
                _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),

        // Floating Action Button Theme - minimal
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),

        // Input Decoration Theme - minimal borders
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: borderColor, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: borderColor, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryColor, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: errorColor, width: 0.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: errorColor, width: 1),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textTertiary),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          selectedColor: primaryColor.withValues(alpha: 0.15),
          disabledColor: surfaceVariant.withValues(alpha: 0.5),
          labelStyle: _textTheme.labelMedium,
          secondaryLabelStyle: _textTheme.labelMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingXs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: dividerColor,
          thickness: 0.5,
          space: spacingMd,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(color: textSecondary, size: 24),

        // Text Theme - System font for clean look
        textTheme: _textTheme,

        // Page Transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // ============================================
  // TEXT THEME - System font for clean look
  // ============================================

  static TextTheme get _textTheme => const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: textPrimary,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: textSecondary,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textSecondary,
        ),
      );
}

/// Extension for easy access to semantic colors in BuildContext
extension AppThemeExtension on BuildContext {
  /// Get the theme data from context
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;

  Color get primaryColor => AppTheme.primaryColor;
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;
  Color get errorColor => AppTheme.errorColor;
  Color get infoColor => AppTheme.infoColor;

  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textTertiary => AppTheme.textTertiary;
  Color get backgroundColor => AppTheme.backgroundColor;
  Color get surfaceColor => AppTheme.surfaceColor;
  Color get borderColor => AppTheme.borderColor;

  double get spacingXs => AppTheme.spacingXs;
  double get spacingSm => AppTheme.spacingSm;
  double get spacingMd => AppTheme.spacingMd;
  double get spacingLg => AppTheme.spacingLg;
  double get spacingXl => AppTheme.spacingXl;

  double get radiusSm => AppTheme.radiusSm;
  double get radiusMd => AppTheme.radiusMd;
  double get radiusLg => AppTheme.radiusLg;
}
