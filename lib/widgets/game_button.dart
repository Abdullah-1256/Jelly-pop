import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Bubbly 3D game button with glossy highlight and press animation.
class GameButton extends StatefulWidget {
  final String label;
  final String? icon;
  final VoidCallback onPressed;
  final bool purple;
  final double? width;
  final double minWidth;
  final double minHeight;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.purple = false,
    this.width,
    this.minWidth = 128,
    this.minHeight = 54,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color fill = widget.purple
        ? AppColors.purpleFill
        : AppColors.greenFill;
    final Color border = widget.purple
        ? AppColors.purpleBorder
        : AppColors.greenBorder;
    final Color top = Color.lerp(fill, AppColors.textLight, 0.28)!;
    final Color bottom = Color.lerp(fill, AppColors.text, 0.16)!;
    final double yOffset = _pressed ? 2 : (widget.minHeight < 45 ? 4 : 6);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
          child: CustomPaint(
            painter: _Button3DPainter(
              border: border,
              shadowOffset: yOffset,
              pressed: _pressed,
              borderRadius: widget.minHeight < 45 ? 18 : 30,
            ),
            child: Container(
              width: widget.width,
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.minHeight < 45 ? 12 : 26,
                vertical: widget.minHeight < 45 ? 8 : 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  widget.minHeight < 45 ? 18 : 30,
                ),
                border: Border.all(
                  color: border,
                  width: widget.minHeight < 45 ? 3 : 4,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[top, fill, bottom],
                  stops: const <double>[0, 0.52, 1],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: border.withValues(alpha: _pressed ? 0.18 : 0.34),
                    blurRadius: _pressed ? 5 : 10,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 0,
                    height: widget.minHeight < 45 ? 8 : 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.textLight.withValues(alpha: 0.55),
                            AppColors.textLight.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Image.asset(
                          widget.icon!,
                          width: widget.minHeight * 0.45,
                          height: widget.minHeight * 0.45,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w800,
                          fontSize: widget.minHeight < 45 ? 16 : 20,
                          shadows: const <Shadow>[
                            Shadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 2),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Button3DPainter extends CustomPainter {
  final Color border;
  final double shadowOffset;
  final bool pressed;
  final double borderRadius;

  const _Button3DPainter({
    required this.border,
    required this.shadowOffset,
    required this.pressed,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect base = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, shadowOffset, size.width, size.height),
      Radius.circular(borderRadius),
    );
    final Paint depthPaint = Paint()
      ..color = Color.lerp(
        border,
        Colors.black,
        0.18,
      )!.withValues(alpha: pressed ? 0.38 : 0.68);
    canvas.drawRRect(base, depthPaint);

    final RRect glow = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height * 0.5),
      Radius.circular(borderRadius - 2),
    );
    final Paint shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: pressed ? 0.16 : 0.34),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(glow.outerRect);
    canvas.drawRRect(glow, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _Button3DPainter oldDelegate) {
    return oldDelegate.border != border ||
        oldDelegate.shadowOffset != shadowOffset ||
        oldDelegate.pressed != pressed ||
        oldDelegate.borderRadius != borderRadius;
  }
}
