import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../models/level.dart';
import '../providers/level_provider.dart';
import '../routes/routes.dart';
import '../widgets/game_button.dart';
import '../widgets/lives_dialog.dart';
import '../widgets/resource_pill.dart';
import '../widgets/top_hud.dart';
import '../widgets/zig_zag_level_map.dart';
import 'main_shell_screen.dart';

/// World map route wrapper that delegates to the persistent tab shell.
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(initialRoute: AppRoutes.mapRoute);
  }
}

/// World map tab content with all level nodes and unlock state.
class WorldMapContent extends StatelessWidget {
  const WorldMapContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LevelProvider levels = context.watch<LevelProvider>();
    return Column(
      children: <Widget>[
        const TopHud(),
        const SizedBox(height: AppSizes.gap),
        Expanded(
          child: ZigZagLevelMap(
            levels: levels.levels,
            highestUnlockedLevel: levels.progress.highestUnlockedLevel,
            starsByLevel: levels.progress.levelStars,
            isUnlocked: levels.isUnlocked,
            onLevelTap: (int id) => _showLevelStart(context, levels, id),
          ),
        ),
      ],
    );
  }

  Future<void> _showLevelStart(
    BuildContext context,
    LevelProvider levels,
    int levelId,
  ) async {
    final GoRouter router = GoRouter.of(context);
    await levels.refreshHeartsIfDue();
    if (!context.mounted) {
      return;
    }
    if (!levels.canPlayLevel) {
      showDialog<void>(
        context: context,
        builder: (_) => const NoHeartsDialog(),
      );
      return;
    }
    final Level level = levels.levelById(levelId);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return LevelStartDialog(
          levelId: levelId,
          moves: level.moves,
          targetScore: level.targetScore,
          bestScore: levels.progress.levelBestScore[levelId] ?? 0,
          hearts: levels.hearts,
          onStart: () {
            Navigator.of(dialogContext).pop();
            router.push(AppRoutes.gamePath(levelId));
          },
        );
      },
    );
  }
}

/// Popup shown before a level starts.
class LevelStartDialog extends StatelessWidget {
  final int levelId;
  final int moves;
  final int targetScore;
  final int bestScore;
  final int hearts;
  final VoidCallback onStart;

  const LevelStartDialog({
    super.key,
    required this.levelId,
    required this.moves,
    required this.targetScore,
    required this.bestScore,
    required this.hearts,
    required this.onStart,
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
          border: Border.all(color: AppColors.greenBorder, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(AppAssets.logo, width: 140),
            Text(
              'Level $levelId',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSizes.gap),
            ResourcePill(asset: AppAssets.heart, value: '$hearts'),
            const SizedBox(height: AppSizes.smallGap),
            Text(
              'Moves: $moves  Target: $targetScore',
              textAlign: TextAlign.center,
            ),
            Text('Best: $bestScore', textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.gap),
            GameButton(label: 'START', onPressed: onStart),
          ],
        ),
      ),
    );
  }
}
