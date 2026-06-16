import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

/// Glassy 3D play button used on the welcome screen.
class GlassPlayButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;

  const GlassPlayButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.width,
  });

  @override
  State<GlassPlayButton> createState() => _GlassPlayButtonState();
}

class _GlassPlayButtonState extends State<GlassPlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double depth = AppSizes.glassButtonDepth;
    final double topOffset = _isPressed ? depth * 0.7 : 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.width,
        height: AppSizes.buttonHeight + depth,
        child: Stack(
          children: <Widget>[
            // Bottom "Base" (the depth)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: AppSizes.buttonHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.playButton.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(
                    AppSizes.glassButtonRadius,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            // Top "Button Face" with animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              top: topOffset,
              height: AppSizes.buttonHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.playButton,
                  borderRadius: BorderRadius.circular(
                    AppSizes.glassButtonRadius,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.78),
                    width: 2.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.72),
                      AppColors.playButton,
                      AppColors.playButton.withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Top Highlight Sparkle
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 4,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.glassHighlight.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
