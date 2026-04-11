import 'package:flutter/material.dart';

/// 蜡笔美学配色（温暖大地色系）
class CrayonTheme {
  CrayonTheme._();

  // 核心颜色
  static const Color forestGreen = Color(0xFF4A7C59);
  static const Color mustardYellow = Color(0xFFE5B844);
  static const Color brickRed = Color(0xFFB8472A);
  static const Color creamWhite = Color(0xFFF5F1E6);
  static const Color darkBrown = Color(0xFF3D2914);
  static const Color softPink = Color(0xFFF8E4E1);

  // 按钮颜色
  static const Color softBlue = Color(0xFFE1EEF8);
  static const Color darkBlue = Color(0xFF2E5C8A);
  static const Color softRed = Color(0xFFF8E4E1);
  static const Color darkRed = Color(0xFFB8472A);

  // 辅助颜色
  static const Color lightGreen = Color(0xFF6B9B7A);
  static const Color warmOrange = Color(0xFFD4956A);
  static const Color skyBlue = Color(0xFF7BA3C9);

  // 间距
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // 圆角
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // 手绘边框参数
  static const double borderWiggleAmount = 3.0;
  static const double borderWidth = 2.5;

  // 获取蜡笔风格文字主题
  static TextTheme get crayonTextTheme => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: darkBrown,
      letterSpacing: 0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: darkBrown,
      letterSpacing: 0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: darkBrown,
      letterSpacing: 0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: darkBrown,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: darkBrown,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkBrown,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: darkBrown,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: forestGreen,
    ),
  );
}