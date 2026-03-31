import 'package:flutter/material.dart';

/// CoinGlass-inspired Material 3 Light Theme
///
/// Design tokens based on CoinGlass visual identity:
/// - Primary: Vibrant Orange (#FF6B35) - energetic, financial
/// - Background: Pure White (#FFFFFF) - clean, professional
/// - Surface: Light Gray (#F5F5F5) - subtle depth
/// - Cards: 16dp rounded corners with subtle border
class AppTheme {
  AppTheme._();

  // ============================================
  // CORE COLOR TOKENS
  // ============================================

  /// Primary brand color - CoinGlass signature orange
  static const Color primaryColor = Color(0xFFFF6B35);

  /// Primary variant for emphasis states
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE55A28);

  /// Background colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color surfaceVariant = Color(0xFFE8E8E8);

  /// Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Border and divider colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // ============================================
  // SEMANTIC STATUS COLORS
  // ============================================

  /// Success - for positive trends, confirmations
  static const Color successColor = Color(0xFF00E676);
  static const Color successLight = Color(0xFF69F0AE);
  static const Color successDark = Color(0xFF00C853);

  /// Warning - for alerts, caution states
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFF8F00);

  /// Error - for errors, negative trends, destructive actions
  static const Color errorColor = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFF8A80);
  static const Color errorDark = Color(0xFFD32F2F);

  /// Info - for informational states
  static const Color infoColor = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

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

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // ELEVATION & SHADOWS
  // ============================================

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
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

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      centerTitle: false,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme - 16dp rounded corners with border
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated Button Theme
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
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textTertiary),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primaryColor.withValues(alpha: 0.2),
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
      thickness: 1,
      space: spacingMd,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: textSecondary, size: 24),

    // Text Theme - Inter font with system fallback
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
  // TEXT THEME - Inter or system fallback
  // ============================================

  static TextTheme get _textTheme => const TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: textPrimary,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: textPrimary,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textSecondary,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
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

  double get spacingXs => AppTheme.spacingXs;
  double get spacingSm => AppTheme.spacingSm;
  double get spacingMd => AppTheme.spacingMd;
  double get spacingLg => AppTheme.spacingLg;
  double get spacingXl => AppTheme.spacingXl;

  double get radiusSm => AppTheme.radiusSm;
  double get radiusMd => AppTheme.radiusMd;
  double get radiusLg => AppTheme.radiusLg;
}
