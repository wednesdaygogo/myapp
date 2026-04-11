import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 蜡笔风格卡片（简单边框，避免多余线条）
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
          border: Border.all(
            color: borderColor,
            width: CrayonTheme.borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}