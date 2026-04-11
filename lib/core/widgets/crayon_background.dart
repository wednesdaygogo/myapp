import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 纸张纹理背景（简洁版本，避免绘制奇怪线条）
class CrayonBackground extends StatelessWidget {
  final Widget child;

  const CrayonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 简洁背景，只使用纯色+微妙的渐变，避免绘制噪点线条
    return Container(
      color: CrayonTheme.creamWhite,
      child: child,
    );
  }
}