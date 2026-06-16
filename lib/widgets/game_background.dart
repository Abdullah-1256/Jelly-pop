import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Full-screen responsive image background with a polished dark overlay.
class GameBackground extends StatelessWidget {
  final String asset;
  final Widget child;
  final bool extraDark;

  const GameBackground({
    super.key,
    required this.asset,
    required this.child,
    this.extraDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: Image.asset(asset, fit: BoxFit.cover)),
        Positioned.fill(child: _buildBackgroundOverlay()),
        if (extraDark)
          const Positioned.fill(
            child: ColoredBox(color: AppColors.backgroundMapShade),
          ),
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildBackgroundOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.backgroundBlackSoft,
            AppColors.backgroundColorWash,
            AppColors.backgroundBlackOverlay,
          ],
          stops: const <double>[0, 0.48, 1],
        ),
      ),
    );
  }
}
