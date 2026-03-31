import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme mode provider - controls light/dark theme selection
/// Currently only supports light theme (CoinGlass-inspired)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

/// Provider for the current ThemeData
/// Returns the CoinGlass-inspired light theme
///
/// Note: When dark theme is added, this will switch based on themeModeProvider
final themeProvider = Provider<ThemeData>((ref) {
  // Currently only light theme is implemented
  return AppTheme.lightTheme;
});

/// Provider for quick access to design tokens
final designTokensProvider = Provider<DesignTokens>((ref) {
  return DesignTokens.instance;
});

/// Design tokens class for consistent access to spacing, colors, and radii
class DesignTokens {
  DesignTokens._();

  static final instance = DesignTokens._();

  // Colors
  Color get primary => AppTheme.primaryColor;
  Color get primaryLight => AppTheme.primaryLight;
  Color get primaryDark => AppTheme.primaryDark;
  Color get background => AppTheme.backgroundColor;
  Color get surface => AppTheme.surfaceColor;
  Color get surfaceVariant => AppTheme.surfaceVariant;

  // Text colors
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textTertiary => AppTheme.textTertiary;
  Color get textOnPrimary => AppTheme.textOnPrimary;

  // Borders and dividers
  Color get border => AppTheme.borderColor;
  Color get divider => AppTheme.dividerColor;

  // Status colors
  Color get success => AppTheme.successColor;
  Color get successLight => AppTheme.successLight;
  Color get successDark => AppTheme.successDark;
  Color get warning => AppTheme.warningColor;
  Color get warningLight => AppTheme.warningLight;
  Color get warningDark => AppTheme.warningDark;
  Color get error => AppTheme.errorColor;
  Color get errorLight => AppTheme.errorLight;
  Color get errorDark => AppTheme.errorDark;
  Color get info => AppTheme.infoColor;
  Color get infoLight => AppTheme.infoLight;
  Color get infoDark => AppTheme.infoDark;

  // Spacing
  double get spacingXs => AppTheme.spacingXs;
  double get spacingSm => AppTheme.spacingSm;
  double get spacingMd => AppTheme.spacingMd;
  double get spacingLg => AppTheme.spacingLg;
  double get spacingXl => AppTheme.spacingXl;
  double get spacingXxl => AppTheme.spacingXxl;

  // Border radius
  double get radiusSm => AppTheme.radiusSm;
  double get radiusMd => AppTheme.radiusMd;
  double get radiusLg => AppTheme.radiusLg;
  double get radiusXl => AppTheme.radiusXl;
  double get radiusFull => AppTheme.radiusFull;

  // Shadows
  List<BoxShadow> get shadowSm => AppTheme.shadowSm;
  List<BoxShadow> get shadowMd => AppTheme.shadowMd;
  List<BoxShadow> get shadowLg => AppTheme.shadowLg;

  // Convenience methods for EdgeInsets
  EdgeInsets get paddingXs => const EdgeInsets.all(AppTheme.spacingXs);
  EdgeInsets get paddingSm => const EdgeInsets.all(AppTheme.spacingSm);
  EdgeInsets get paddingMd => const EdgeInsets.all(AppTheme.spacingMd);
  EdgeInsets get paddingLg => const EdgeInsets.all(AppTheme.spacingLg);
  EdgeInsets get paddingXl => const EdgeInsets.all(AppTheme.spacingXl);

  EdgeInsets get horizontalPaddingSm =>
      const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm);
  EdgeInsets get horizontalPaddingMd =>
      const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd);
  EdgeInsets get horizontalPaddingLg =>
      const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg);

  EdgeInsets get verticalPaddingSm =>
      const EdgeInsets.symmetric(vertical: AppTheme.spacingSm);
  EdgeInsets get verticalPaddingMd =>
      const EdgeInsets.symmetric(vertical: AppTheme.spacingMd);
  EdgeInsets get verticalPaddingLg =>
      const EdgeInsets.symmetric(vertical: AppTheme.spacingLg);

  // Convenience methods for BorderRadius
  BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);
}
