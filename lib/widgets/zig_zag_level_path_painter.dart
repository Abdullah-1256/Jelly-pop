import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Paints a curved rope trail connecting level nodes.
class ZigZagLevelPathPainter extends CustomPainter {
  final List<Offset> points;
  final double motionOffset;

  const ZigZagLevelPathPainter({required this.points, this.motionOffset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }
    final Path path = _buildSmoothPath();
    _drawRopeBase(canvas, path);
    _drawRopeWraps(canvas);
  }

  Path _buildSmoothPath() {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int index = 1; index < points.length - 1; index++) {
      final Offset current = points[index];
      final Offset next = points[index + 1];
      final Offset mid = Offset(
        (current.dx + next.dx) * 0.5,
        (current.dy + next.dy) * 0.5,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  void _drawRopeBase(Canvas canvas, Path path) {
    final Paint shadowPaint = Paint()
      ..color = AppColors.ropeShadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path.shift(const Offset(0, 8)), shadowPaint);

    final Paint borderPaint = Paint()
      ..color = AppColors.ropeDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    final Paint fillPaint = Paint()
      ..color = AppColors.ropeBase
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, fillPaint);

    final Paint highlightPaint = Paint()
      ..color = AppColors.ropeLight.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path.shift(const Offset(-2, -3)), highlightPaint);
  }

  void _drawRopeWraps(Canvas canvas) {
    final Paint wrapPaint = Paint()
      ..color = AppColors.ropeLight.withValues(alpha: 0.92)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int index = 0; index < points.length - 1; index++) {
      _drawSegmentWraps(
        canvas,
        points[index],
        points[index + 1],
        wrapPaint,
        index,
      );
    }
  }

  void _drawSegmentWraps(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint wrapPaint,
    int segmentIndex,
  ) {
    final Offset delta = end - start;
    final double distance = delta.distance;
    if (distance <= 0) {
      return;
    }
    final Offset direction = delta / distance;
    final Offset normal = Offset(-direction.dy, direction.dx);
    final double angleSign = direction.dx >= 0 ? 1 : -1;
    final double phase = (motionOffset * 0.28 + segmentIndex * 7) % 22;
    for (double step = 18 - phase; step < distance; step += 22) {
      if (step < 8) {
        continue;
      }
      final Offset center = start + (direction * step);
      final Offset lean = direction * (9 * angleSign);
      final Offset edge = normal * 10;
      canvas.drawLine(center - edge - lean, center + edge + lean, wrapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ZigZagLevelPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.motionOffset != motionOffset;
  }
}
