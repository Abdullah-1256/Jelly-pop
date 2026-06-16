import '../../models/candy.dart';
import '../../models/game_state.dart';
import '../../models/level.dart';

/// Evaluates win, loss, and star thresholds for a level.
class LevelChecker {
  /// Returns true when all collection goals are complete.
  bool isWin(GameState state, Level level) {
    if (level.collectTargets.isEmpty) {
      return false; // Should not happen with new level data
    }
    // Check collection targets
    for (final MapEntry<CandyType, int> target
        in level.collectTargets.entries) {
      if ((state.collectedTargets[target.key] ?? 0) < target.value) {
        return false;
      }
    }
    return true;
  }

  /// Returns true when the move counter has expired and targets aren't met.
  bool isLose(GameState state, Level level) {
    return state.movesLeft <= 0 && !isWin(state, level);
  }

  /// Calculates the earned star count for a final score.
  int starsForScore({required int score, required Level level}) {
    if (score >= level.starThreshold3) {
      return 3;
    }
    if (score >= level.starThreshold2) {
      return 2;
    }
    return 1; // Minimum 1 star for completing collection targets
  }
}
