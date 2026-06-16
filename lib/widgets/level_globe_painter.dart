import 'package:flutter/material.dart';

/// Draws rotating globe latitude and meridian lines over a level node.
class LevelGlobePainter extends CustomPainter {
  final Color lineColor;

  const LevelGlobePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(rect.deflate(size.width * 0.18), paint);
    canvas.drawArc(rect.deflate(size.width * 0.10), 0.4, 2.25, false, paint);
    canvas.drawArc(rect.deflate(size.width * 0.10), 3.55, 2.25, false, paint);
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.5),
      Offset(size.width * 0.84, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.12),
      Offset(size.width * 0.5, size.height * 0.88),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LevelGlobePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
