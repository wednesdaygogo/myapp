import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';
import 'crayon_painters.dart';

/// 蜡笔风格卡片（手绘边框）
class CrayonCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const CrayonCard({
    super.key,
    required this.child,
    this.backgroundColor = CrayonTheme.creamWhite,
    this.borderColor = CrayonTheme.darkBrown,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(CrayonTheme.spacingMd);
    final borderWidth = CrayonTheme.borderWidth;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 给边框留出空间
        padding: EdgeInsets.all(borderWidth + 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
        ),
        child: Stack(
          children: [
            // 手绘边框（底层）
            Positioned.fill(
              child: CustomPaint(
                painter: WigglyBorderPainter(
                  borderColor: borderColor,
                  radius: CrayonTheme.radiusMd - borderWidth,
                ),
              ),
            ),
            // 内容（顶层）- 带内边距避开边框
            Padding(
              padding: effectivePadding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}