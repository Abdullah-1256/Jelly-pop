import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../providers/level_provider.dart';
import 'asset_icon.dart';

/// A shared top HUD showing level, hearts, and coins without overflow.
class TopHud extends StatelessWidget {
  final bool showBackButton;

  const TopHud({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    final int level = levels.progress.highestUnlockedLevel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.36),
          width: 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildStatPill(
              context: context,
              asset: AppAssets.logo,
              value: 'Level $level',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildStatPill(
              context: context,
              asset: AppAssets.heart,
              value: '${levels.hearts}',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildStatPill(
              context: context,
              asset: AppAssets.coin,
              value: '${levels.coins}',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildStatPill(
              context: context,
              asset: AppAssets.gem,
              value: '${levels.gems}',
              iconSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required BuildContext context,
    required String asset,
    required String value,
    double iconSize = 36,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.textLight.withValues(alpha: 0.5)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: asset, size: iconSize),
            const SizedBox(width: 5),
            Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
