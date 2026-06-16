import '../game/game_controller.dart';
import '../models/level.dart';
import 'level_provider.dart';

/// Provider facade for gameplay state and controller actions.
class GameProvider extends MatchGameController {
  LevelProvider? _levels;

  GameProvider(super.audioManager);

  /// Attaches level progress services to gameplay.
  void attachLevels(LevelProvider levels) {
    _levels = levels;
  }

  /// Starts a level by id from the loaded level data.
  Future<void> startLevelById(int levelId) async {
    final Level level = _levels!.levelById(levelId);
    await startLevel(level);
  }

  /// Saves completion progress when the current level is won.
  Future<void> saveWinProgress() async {
    final Level? activeLevel = level;
    final int? score = state?.score;
    if (activeLevel == null || score == null) {
      return;
    }
    await _levels?.completeLevel(
      levelId: activeLevel.id,
      score: score,
      stars: stars,
    );
  }
}
