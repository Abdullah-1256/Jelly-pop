import '../../models/candy.dart';
import '../../models/level.dart';

typedef MovementRecord = ({
  String candyId,
  int fromRow,
  int fromCol,
  int toRow,
  int toCol,
});

/// Applies column gravity after candies are removed.
class GravityHandler {
  /// Shifts candies downward and returns movement records for animation.
  List<MovementRecord> applyGravity(List<List<Candy?>> grid, Level level) {
    final List<MovementRecord> movements = <MovementRecord>[];
    for (int col = 0; col < level.gridCols; col++) {
      int writeRow = level.gridRows - 1;
      for (int row = level.gridRows - 1; row >= 0; row--) {
        if (level.isBlocked(row: row, col: col)) {
          writeRow = row - 1;
          continue;
        }
        final Candy? candy = grid[row][col];
        if (candy == null) {
          continue;
        }
        if (row != writeRow) {
          grid[writeRow][col] = candy.copyWith(row: writeRow, col: col);
          grid[row][col] = null;
          movements.add((
            candyId: candy.id,
            fromRow: row,
            fromCol: col,
            toRow: writeRow,
            toCol: col,
          ));
        }
        writeRow--;
      }
    }
    return movements;
  }
}
