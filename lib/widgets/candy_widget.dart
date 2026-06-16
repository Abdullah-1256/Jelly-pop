import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../models/candy.dart';
import 'animated_candy.dart';

/// Paints an image-driven jelly candy with optimized decorations for performance.
class CandyWidget extends StatelessWidget {
  final Candy candy;
  final bool selected;
  final bool isSwapping;
  final bool hint;
  final VoidCallback? onTap;
  final ValueChanged<DragEndDetails>? onPanEnd;

  const CandyWidget({
    super.key,
    required this.candy,
    required this.selected,
    required this.isSwapping,
    required this.hint,
    this.onTap,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanEnd: onPanEnd,
      child: AnimatedCandy(
        selected: selected,
        isSwapping: isSwapping,
        hint: hint,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _buildShadows(),
          ),
          child: Image.asset(
            AppAssets.candyImageFor(candy),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.low,
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadows() {
    // Only show enhanced shadow when actively swapping
    if (isSwapping) {
      return <BoxShadow>[
        BoxShadow(
          color: AppColors.secondary.withValues(alpha: 0.7),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ];
    }

    // Default subtle shadow for all other candies
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }
}
