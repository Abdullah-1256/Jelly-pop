import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'asset_icon.dart';
import 'level_globe_painter.dart';

/// Circular map level node with orbit and scroll-roll animation.
class LevelOrb extends StatefulWidget {
  final int levelId;
  final bool unlocked;
  final bool active;
  final int stars;
  final double size;
  final ValueListenable<double> scrollOffset;
  final VoidCallback onTap;

  const LevelOrb({
    super.key,
    required this.levelId,
    required this.unlocked,
    required this.active,
    required this.stars,
    required this.size,
    required this.scrollOffset,
    required this.onTap,
  });

  @override
  State<LevelOrb> createState() => _LevelOrbState();
}

class _LevelOrbState extends State<LevelOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LevelOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    }
    if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color fill = widget.unlocked
        ? AppColors.greenFill.withValues(alpha: 0.96)
        : AppColors.locked.withValues(alpha: 0.9);
    final Color border = widget.unlocked
        ? AppColors.greenBorder
        : AppColors.panelDark;
    return GestureDetector(
      onTap: widget.unlocked ? widget.onTap : null,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            if (widget.active) _buildOrbit(),
            _buildOrb(fill: fill, border: border),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb({required Color fill, required Color border}) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(child: _buildOrbFill(fill)),
              Positioned.fill(child: _buildRollingGlobeLines()),
              Center(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbFill(Color fill) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.32, -0.38),
          colors: <Color>[
            AppColors.textLight,
            fill,
            Color.lerp(fill, AppColors.text, 0.18)!,
          ],
        ),
      ),
    );
  }

  Widget _buildRollingGlobeLines() {
    return AnimatedBuilder(
      animation: widget.scrollOffset,
      builder: (_, _) {
        final double angle = widget.scrollOffset.value / widget.size;
        return Transform.rotate(
          angle: angle,
          child: CustomPaint(
            painter: LevelGlobePainter(
              lineColor: AppColors.textLight.withValues(alpha: 0.34),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!widget.unlocked) {
      return const AssetIconImage(asset: AppAssets.locked, size: 30);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${widget.levelId}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w800,
            shadows: const <Shadow>[
              Shadow(color: AppColors.shadowStrong, offset: Offset(0, 2)),
            ],
          ),
        ),
        if (widget.stars > 0)
          AssetIconImage(asset: AppAssets.starFilled, size: widget.size * 0.24),
      ],
    );
  }

  Widget _buildOrbit() {
    final double radius = widget.size * 0.58;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, Widget? child) {
        final double angle = _controller.value * math.pi * 2;
        return Transform.translate(
          offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
          child: child,
        );
      },
      child: Container(
        width: AppSizes.gap,
        height: AppSizes.gap,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textLight, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: AppColors.accent, blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
