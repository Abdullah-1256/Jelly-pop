import '../models/candy.dart';
import '../models/level.dart';

/// Static level definitions for the match-3 map.
abstract class LevelsData {
  static const int totalLevels = 30;
  static const int movesPerLevel = 15;

  /// Returns all playable levels.
  static final List<Level> levels = List<Level>.generate(
    totalLevels,
    (int index) => _buildLevel(index + 1),
  );

  static Level _buildLevel(int id) {
    final int targetScore = _targetScore(id);
    return Level(
      id: id,
      moves: movesPerLevel,
      targetScore: targetScore,
      gridRows: 8,
      gridCols: 8,
      collectTargets: _collectTargets(id),
      blockedCells: _blockedCells(id),
      starThreshold2: targetScore + 300,
      starThreshold3: targetScore + 650,
    );
  }

  static int _targetScore(int id) => 300 + (id * 35);

  static Map<CandyType, int> _collectTargets(int id) {
    if (id <= 3) {
      // Add simple targets for introductory levels
      return <CandyType, int>{CandyType.red: 3 + id};
    }
    final CandyType first = CandyType.values[id % CandyType.values.length];
    if (id < 10) {
      return <CandyType, int>{first: 4 + (id % 3)};
    }
    final CandyType second =
        CandyType.values[(id + 2) % CandyType.values.length];
    return <CandyType, int>{first: 5 + (id % 4), second: 4 + (id % 3)};
  }

  static Set<String> _blockedCells(int id) {
    if (id < 8) {
      return const <String>{};
    }
    if (id < 16) {
      return const <String>{'3,3', '3,4', '4,3', '4,4'};
    }
    if (id < 24) {
      return const <String>{'2,2', '2,5', '5,2', '5,5'};
    }
    return const <String>{'1,3', '1,4', '3,1', '3,6', '6,3', '6,4'};
  }
}
