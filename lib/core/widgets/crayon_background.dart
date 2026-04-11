import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 纸张纹理背景（使用程序生成的噪点纹理）
class CrayonBackground extends StatelessWidget {
  final Widget child;

  const CrayonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CrayonTheme.creamWhite,
      child: Stack(
        children: [
          // 纹理层（使用CustomPaint生成噪点）
          Positioned.fill(
            child: CustomPaint(
              painter: _PaperTexturePainter(),
            ),
          ),
          // 内容层
          child,
        ],
      ),
    );
  }
}

/// 纸张纹理绘制器
class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制微妙的噪点纹理
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03);

    for (int i = 0; i < size.width; i += 4) {
      for (int j = 0; j < size.height; j += 4) {
        if ((i + j) % 8 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i.toDouble(), j.toDouble(), 2, 2),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) => false;
}