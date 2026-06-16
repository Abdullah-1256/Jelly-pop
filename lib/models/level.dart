import 'candy.dart';

/// Immutable level configuration used by the game controller.
class Level {
  final int id;
  final int moves;
  final int targetScore;
  final int gridRows;
  final int gridCols;
  final Map<CandyType, int> collectTargets;
  final Set<String> blockedCells;
  final int starThreshold2;
  final int starThreshold3;

  const Level({
    required this.id,
    required this.moves,
    required this.targetScore,
    required this.gridRows,
    required this.gridCols,
    required this.collectTargets,
    required this.blockedCells,
    required this.starThreshold2,
    required this.starThreshold3,
  });

  /// Returns true when this coordinate is blocked.
  bool isBlocked({required int row, required int col}) {
    return blockedCells.contains('$row,$col');
  }
}
