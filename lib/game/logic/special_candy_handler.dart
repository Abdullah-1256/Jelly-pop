import '../../models/candy.dart';
import '../../models/level.dart';
import '../board/match_detector.dart';

/// Resolves the affected cells for activated special candies.
class SpecialCandyHandler {
  /// Calculates all cells cleared by a special candy.
  Set<BoardPoint> affectedCells({
    required Candy specialCandy,
    required Candy? swappedWith,
    required List<List<Candy?>> grid,
    required Level level,
  }) {
    final Set<BoardPoint> cells = <BoardPoint>{};
    switch (specialCandy.specialType) {
      case SpecialType.stripedH:
        for (int col = 0; col < level.gridCols; col++) {
          cells.add((row: specialCandy.row, col: col));
        }
      case SpecialType.stripedV:
        for (int row = 0; row < level.gridRows; row++) {
          cells.add((row: row, col: specialCandy.col));
        }
      case SpecialType.wrapped:
        for (
          int row = specialCandy.row - 1;
          row <= specialCandy.row + 1;
          row++
        ) {
          for (
            int col = specialCandy.col - 1;
            col <= specialCandy.col + 1;
            col++
          ) {
            if (row >= 0 &&
                col >= 0 &&
                row < level.gridRows &&
                col < level.gridCols) {
              cells.add((row: row, col: col));
            }
          }
        }
      case SpecialType.colorBomb:
        final CandyType? type = swappedWith?.type;
        for (int row = 0; row < level.gridRows; row++) {
          for (int col = 0; col < level.gridCols; col++) {
            if (type == null || grid[row][col]?.type == type) {
              cells.add((row: row, col: col));
            }
          }
        }
      case SpecialType.none:
        cells.add((row: specialCandy.row, col: specialCandy.col));
    }
    return cells.where((BoardPoint point) {
      return !level.isBlocked(row: point.row, col: point.col);
    }).toSet();
  }
}
