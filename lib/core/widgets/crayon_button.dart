import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 蜡笔风格按钮（简单边框）
class CrayonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CrayonButtonType type;
  final IconData? icon;
  final bool isFullWidth;

  const CrayonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CrayonButtonType.primary,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(type);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: CrayonTheme.spacingMd,
          vertical: CrayonTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
          border: Border.all(
            color: colors.border,
            width: CrayonTheme.borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: colors.text, size: 18),
            if (icon != null) const SizedBox(width: CrayonTheme.spacingSm),
            Text(
              text,
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ButtonColors _getColors(CrayonButtonType type) {
    switch (type) {
      case CrayonButtonType.primary:
        return _ButtonColors(
          background: CrayonTheme.softBlue,
          border: CrayonTheme.darkBlue,
          text: CrayonTheme.darkBlue,
        );
      case CrayonButtonType.secondary:
        return _ButtonColors(
          background: CrayonTheme.creamWhite,
          border: CrayonTheme.darkBrown,
          text: CrayonTheme.darkBrown,
        );
      case CrayonButtonType.danger:
        return _ButtonColors(
          background: CrayonTheme.softRed,
          border: CrayonTheme.darkRed,
          text: CrayonTheme.darkRed,
        );
    }
  }
}

/// 按钮类型
enum CrayonButtonType {
  primary,
  secondary,
  danger,
}

/// 按钮颜色组合
class _ButtonColors {
  final Color background;
  final Color border;
  final Color text;

  _ButtonColors({
    required this.background,
    required this.border,
    required this.text,
  });
}