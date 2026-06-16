import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/level_provider.dart';
import '../../../routes/routes.dart';
import '../../../widgets/asset_icon.dart';
import '../../../widgets/jelly_back_button.dart';

/// Displays the level, moves, score, and currency during gameplay.
class GameLevelInfoHud extends StatelessWidget {
  final GameProvider game;

  const GameLevelInfoHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    final int moves = game.state?.movesLeft ?? 0;
    final int score = game.state?.score ?? 0;
    final int levelId = game.level?.id ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.4),
          width: 2.5,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 46,
            height: 46,
            child: FittedBox(
              child: JellyBackButton(fallbackRoute: AppRoutes.mapRoute),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _BigInfoPill(
                    icon: AppAssets.logo,
                    label: 'Level',
                    text: '$levelId',
                    color: AppColors.coinYellow.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _BigInfoPill(
                    icon: AppAssets.timer,
                    label: 'Moves',
                    text: '$moves',
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _BigInfoPill(
                    icon: AppAssets.coin,
                    label: 'Score',
                    text: '$score',
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _BigInfoPill(
                    icon: AppAssets.gem,
                    label: 'Gems',
                    text: '${levels.gems}',
                    color: AppColors.gemPurple.withValues(alpha: 0.12),
                    iconSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigInfoPill extends StatelessWidget {
  final String icon;
  final String label;
  final String text;
  final Color color;
  final double iconSize;

  const _BigInfoPill({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: icon, size: iconSize),
            const SizedBox(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: AppColors.text.withValues(alpha: 0.68),
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  text,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.text,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays current collection targets for the active level.
class GameObjectives extends StatelessWidget {
  final GameProvider game;

  const GameObjectives({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final entries = game.level?.collectTargets.entries.toList() ?? const [];
    final List<Widget> children = <Widget>[];

    for (final entry in entries) {
      final int collected = game.state?.collectedTargets[entry.key] ?? 0;
      children.add(
        _ObjectivePill(
          asset: AppAssets.candyFor(entry.key),
          text: '$collected/${entry.value}',
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}

class _ObjectivePill extends StatelessWidget {
  final String asset;
  final String text;

  const _ObjectivePill({required this.asset, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.textLight, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AssetIconImage(asset: asset, size: 34),
          const SizedBox(width: AppSizes.smallGap),
          Text(text),
        ],
      ),
    );
  }
}

/// Shows the selected booster targeting prompt above the board.
class BoosterAimBanner extends StatelessWidget {
  final VoidCallback onCancel;

  const BoosterAimBanner({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Touch any candy where you want to blast',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCancel,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white24,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animates combo celebration text over the board.
class ComboText extends StatelessWidget {
  final String text;

  const ComboText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (BuildContext context, double value, Widget? child) {
            final double elastic = Curves.elasticOut.transform(value);
            final double bump = math.sin(value * math.pi * 3) * (1 - value);
            final double scale = 0.62 + (elastic * 0.48) + (bump * 0.18);
            final double angle =
                math.sin(value * math.pi * 4) * (1 - value) * 0.12;
            final double offsetY = -14 * (1 - value);

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 50,
              color: AppColors.coinYellow,
              fontWeight: FontWeight.w800,
              shadows: const <Shadow>[
                Shadow(
                  color: Color(0xAA7A2B00),
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
                Shadow(color: Colors.white, blurRadius: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
