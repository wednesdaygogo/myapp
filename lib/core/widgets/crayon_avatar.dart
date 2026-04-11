import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/crayon_theme.dart';

/// 预设头像
class PresetAvatars {
  PresetAvatars._();

  static const List<String> names = [
    'bear',
    'fox',
    'cat',
    'dog',
    'panda',
    'polar_bear',
    'rabbit',
    'owl',
  ];

  static const Map<String, String> emojiMap = {
    'bear': '🐻',
    'fox': '🦊',
    'cat': '🐱',
    'dog': '🐶',
    'panda': '🐼',
    'polar_bear': '🐻‍❄️',
    'rabbit': '🐰',
    'owl': '🦉',
  };
}

/// 手绘风格头像组件
class CrayonAvatar extends StatelessWidget {
  final String? presetName; // 预设头像名称
  final String? customImagePath; // 用户上传图片路径
  final double size;
  final Color borderColor;

  const CrayonAvatar({
    super.key,
    this.presetName,
    this.customImagePath,
    this.size = 60,
    this.borderColor = CrayonTheme.darkBrown,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 手绘圆形边框（底层）
          Positioned.fill(
            child: CustomPaint(
              painter: _WigglyCirclePainter(
                borderColor: borderColor,
                borderWidth: 2,
              ),
            ),
          ),
          // 头像内容（顶层）
          Center(
            child: _buildAvatarContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (customImagePath != null && customImagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(customImagePath!),
          width: size - 8,
          height: size - 8,
          fit: BoxFit.cover,
        ),
      );
    }

    if (presetName != null) {
      final emoji = PresetAvatars.emojiMap[presetName!] ?? '👤';
      return Text(emoji, style: TextStyle(fontSize: size * 0.5));
    }

    return Icon(Icons.person, size: size * 0.5, color: AppTheme.textSecondary);
  }
}

/// 手绘风格圆形边框Painter
class _WigglyCirclePainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;

  _WigglyCirclePainter({
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - borderWidth) / 2;

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // 生成 wiggle 点
    const segments = 36;
    final path = Path();

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * 3.14159;
      // 添加随机 wiggle 偏移
      final wiggle = _sin(angle * 6) * 2 + _cos(angle * 4) * 1.5;
      final r = radius + wiggle;

      final x = center.dx + r * _cos(angle);
      final y = center.dy + r * _sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    // 简单近似
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _cos(double x) {
    return _sin(x + 1.5708);
  }

  @override
  bool shouldRepaint(covariant _WigglyCirclePainter oldDelegate) {
    return borderColor != oldDelegate.borderColor || borderWidth != oldDelegate.borderWidth;
  }
}