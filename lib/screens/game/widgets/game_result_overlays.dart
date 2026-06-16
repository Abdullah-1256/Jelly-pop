import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/level_provider.dart';
import '../../../routes/routes.dart';
import '../../../widgets/asset_icon.dart';
import '../../../widgets/game_button.dart';
import '../../../widgets/lives_dialog.dart';

/// Win popup shown after a completed level.
class LevelWinOverlay extends StatelessWidget {
  final int levelId;
  final int score;
  final int stars;

  const LevelWinOverlay({
    super.key,
    required this.levelId,
    required this.score,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final int coinReward = LevelProvider.coinRewardForStars(stars);
    final int gemReward = LevelProvider.gemRewardForStars(stars);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.coinYellow, width: 4),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.coinYellow.withValues(alpha: 0.46),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
                const BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 18,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AssetIconImage(asset: AppAssets.winning, size: 150),
                const SizedBox(height: AppSizes.smallGap),
                Text(
                  'Level $levelId Complete!',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.smallGap),
                _buildStars(),
                const SizedBox(height: AppSizes.gap),
                _buildScoreCard(context),
                const SizedBox(height: AppSizes.smallGap),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildRewardCard(
                        context: context,
                        asset: AppAssets.coin,
                        label: 'Coins',
                        value: '+$coinReward',
                      ),
                    ),
                    const SizedBox(width: AppSizes.smallGap),
                    Expanded(
                      child: _buildRewardCard(
                        context: context,
                        asset: AppAssets.gem,
                        label: 'Gems',
                        value: '+$gemReward',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GameButton(
                        label: AppStrings.menu,
                        purple: true,
                        onPressed: () =>
                            _closeAndGo(context, AppRoutes.mapRoute),
                      ),
                    ),
                    const SizedBox(width: AppSizes.smallGap),
                    Expanded(
                      child: GameButton(
                        label:
                            levelId <
                                context.read<LevelProvider>().levels.length
                            ? AppStrings.next
                            : AppStrings.menu,
                        onPressed: () => _closeAndGo(
                          context,
                          levelId < context.read<LevelProvider>().levels.length
                              ? AppRoutes.gamePath(levelId + 1)
                              : AppRoutes.mapRoute,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int index) {
        final bool earned = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AssetIconImage(
            asset: earned ? AppAssets.starFilled : AppAssets.starEmpty,
            size: earned ? 48 : 40,
          ),
        );
      }),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.coinYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.coinYellow, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const AssetIconImage(asset: AppAssets.starFilled, size: 30),
          const SizedBox(width: AppSizes.smallGap),
          Flexible(
            child: Text(
              'Score: $score points',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({
    required BuildContext context,
    required String asset,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AssetIconImage(asset: asset, size: 36),
          const SizedBox(height: AppSizes.smallGap),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Failed popup shown after a lost level.
class LevelFailedOverlay extends StatelessWidget {
  final int levelId;
  final int heartsLeft;
  final Duration refillRemaining;
  final int score;

  const LevelFailedOverlay({
    super.key,
    required this.levelId,
    required this.heartsLeft,
    required this.refillRemaining,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultPanel(
      asset: AppAssets.mascotSad,
      title: 'Level Failed',
      body: 'Targets not met before moves ran out!',
      scoreText: 'Final Score: $score',
      primaryLabel: 'WATCH AD +5 MOVES',
      onPrimary: () {
        final NavigatorState navigator = Navigator.of(context);
        final GameProvider gameProvider = context.read<GameProvider>();
        navigator.pop();
        showDialog<void>(
          context: navigator.context,
          barrierDismissible: false,
          builder: (_) =>
              RewardedAdDialog(onComplete: () => gameProvider.addExtraMoves(5)),
        );
      },
      secondaryLabel: heartsLeft > 0 ? 'Retry (1 Heart)' : AppStrings.menu,
      onSecondary: heartsLeft > 0
          ? () => _closeAndGo(
              context,
              '${AppRoutes.gamePath(levelId)}?retry=${DateTime.now().millisecondsSinceEpoch}',
            )
          : () => _closeAndGo(context, AppRoutes.mapRoute),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String asset;
  final String title;
  final String body;
  final String scoreText;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const _ResultPanel({
    required this.asset,
    required this.title,
    required this.body,
    required this.scoreText,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.redCandy, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: asset, size: 120),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.redCandy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.smallGap),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.gap),
            _ResultStatRow(
              asset: AppAssets.starFilled,
              label: 'Result',
              value: scoreText,
            ),
            const SizedBox(height: AppSizes.gap * 1.5),
            GameButton(label: primaryLabel, onPressed: onPrimary),
            const SizedBox(height: AppSizes.gap * 2),
            GameButton(
              label: secondaryLabel,
              purple: true,
              onPressed: onSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStatRow extends StatelessWidget {
  final String asset;
  final String label;
  final String value;

  const _ResultStatRow({
    required this.asset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.smallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AssetIconImage(asset: asset, size: 30),
          const SizedBox(width: AppSizes.smallGap),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

void _closeAndGo(BuildContext context, String location) {
  final GoRouter router = GoRouter.of(context);
  Navigator.of(context).pop();
  router.go(location);
}

/// Extra moves popup shown when moves run out.
class ExtraMovesDialog extends StatelessWidget {
  const ExtraMovesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.purpleBorder, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AssetIconImage(asset: AppAssets.gem, size: 110),
            Text(
              'Extra Moves',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Extra moves are not enabled yet. Retry the level for now.',
            ),
            const SizedBox(height: AppSizes.gap),
            GameButton(
              label: 'OK',
              purple: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Booster info popup shown from the game HUD.
class GameBoosterInfoDialog extends StatelessWidget {
  final String title;
  final String asset;

  const GameBoosterInfoDialog({
    super.key,
    required this.title,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.purpleBorder, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssetIconImage(asset: asset, size: 120),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const Text(
              'Boosters are displayed here and ready for future gameplay activation.',
            ),
            const SizedBox(height: AppSizes.gap),
            GameButton(
              label: 'OK',
              purple: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
