import 'package:flutter/material.dart';

import '../core/constants/app_sizes.dart';

/// Professional smooth selection and swap animation with optimized curves.
/// Uses separate animation durations for swap (180ms) vs select (140ms).
/// Only animates when necessary to improve performance on low-end devices.
class AnimatedCandy extends StatefulWidget {
  final Widget child;
  final bool selected;
  final bool isSwapping;
  final bool hint;

  const AnimatedCandy({
    super.key,
    required this.child,
    required this.selected,
    required this.isSwapping,
    required this.hint,
  });

  @override
  State<AnimatedCandy> createState() => _AnimatedCandyState();
}

class _AnimatedCandyState extends State<AnimatedCandy>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late int _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = _getDurationForState();
    _ctrl = AnimationController(
      duration: Duration(milliseconds: _currentDuration),
      vsync: this,
    );
    _setupAnimations();
    _startAnimation();
  }

  int _getDurationForState() {
    if (widget.isSwapping) {
      return AppSizes.swapAnimMs; // 180ms for smooth swap
    }
    if (widget.selected) {
      return AppSizes.selectAnimMs; // 140ms for snappy select
    }
    return AppSizes.selectAnimMs;
  }

  void _setupAnimations() {
    // Target scales with professional proportions
    final double targetScale = widget.isSwapping
        ? 1.15 // Reduced slightly for more professional feel
        : (widget.selected ? 1.10 : 1.0); // Subtle select highlight

    // Professional curves: swap uses easeOutCubic (smooth deceleration),
    // select uses easeOutQuad (snappy but smooth)
    final Curve curve = widget.isSwapping
        ? Curves
              .easeOutCubic // Professional swap deceleration
        : Curves.easeOutQuad; // Quick snap for selection

    _scaleAnim = Tween<double>(
      begin: 0.98, // Subtle starting point (not too extreme)
      end: targetScale,
    ).animate(CurvedAnimation(parent: _ctrl, curve: curve));
  }

  void _startAnimation() {
    if (_ctrl.isAnimating) {
      _ctrl.stop();
    }
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCandy oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only re-animate if selected or isSwapping state changed (NOT hint)
    if (oldWidget.selected != widget.selected ||
        oldWidget.isSwapping != widget.isSwapping) {
      // Update duration if state changes
      final int newDuration = _getDurationForState();
      if (newDuration != _currentDuration) {
        _currentDuration = newDuration;
        _ctrl.duration = Duration(milliseconds: _currentDuration);
      }
      _setupAnimations();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
    );
  }
}
