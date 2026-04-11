import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 手绘歪扭边框绘制器
class WigglyBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wiggleAmount;
  final double radius;

  WigglyBorderPainter({
    this.borderColor = CrayonTheme.darkBrown,
    this.borderWidth = CrayonTheme.borderWidth,
    this.wiggleAmount = CrayonTheme.borderWiggleAmount,
    this.radius = CrayonTheme.radiusMd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createWigglyRRectPath(size);
    canvas.drawPath(path, paint);
  }

  Path _createWigglyRRectPath(Size size) {
    final path = Path();
    final wiggle = wiggleAmount;

    path.moveTo(radius + _randomOffset(wiggle), wiggle + _randomOffset(wiggle));
    path.lineTo(size.width - radius + _randomOffset(wiggle), wiggle + _randomOffset(wiggle));
    path.arcToPoint(Offset(size.width - wiggle + _randomOffset(wiggle), radius + _randomOffset(wiggle)), radius: Radius.circular(radius));
    path.lineTo(size.width - wiggle + _randomOffset(wiggle), size.height - radius + _randomOffset(wiggle));
    path.arcToPoint(Offset(size.width - radius + _randomOffset(wiggle), size.height - wiggle + _randomOffset(wiggle)), radius: Radius.circular(radius));
    path.lineTo(radius + _randomOffset(wiggle), size.height - wiggle + _randomOffset(wiggle));
    path.arcToPoint(Offset(wiggle + _randomOffset(wiggle), size.height - radius + _randomOffset(wiggle)), radius: Radius.circular(radius));
    path.lineTo(wiggle + _randomOffset(wiggle), radius + _randomOffset(wiggle));
    path.arcToPoint(Offset(radius + _randomOffset(wiggle), wiggle + _randomOffset(wiggle)), radius: Radius.circular(radius));

    return path;
  }

  double _randomOffset(double amount) {
    return (DateTime.now().microsecondsSinceEpoch % 1000 / 500 - 1) * amount * 0.3;
  }

  @override
  bool shouldRepaint(covariant WigglyBorderPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth ||
           wiggleAmount != oldDelegate.wiggleAmount ||
           radius != oldDelegate.radius;
  }
}

/// 蜡笔风格折线绘制器（用于图表）
class CrayonLinePainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;
  final double lineWidth;

  CrayonLinePainter({
    required this.points,
    this.lineColor = CrayonTheme.mustardYellow,
    this.lineWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final wiggle = lineWidth * 0.5;
      final dx = points[i].dx + (i % 2 == 0 ? wiggle : -wiggle);
      final dy = points[i].dy + ((i + 1) % 2 == 0 ? wiggle : -wiggle);
      path.lineTo(dx, dy);
    }

    canvas.drawPath(path, paint);

    // 绘制数据点
    final circlePaint = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 6, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CrayonLinePainter oldDelegate) {
    return points != oldDelegate.points ||
           lineColor != oldDelegate.lineColor ||
           lineWidth != oldDelegate.lineWidth;
  }
}