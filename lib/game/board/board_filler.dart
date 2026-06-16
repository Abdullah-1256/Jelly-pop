import 'dart:math';

import '../../models/candy.dart';
import '../../models/level.dart';

/// Creates new candies while avoiding immediate accidental matches.
class BoardFiller {
  final Random _random;
  int _nextId = 0;

  BoardFiller({Random? random}) : _random = random ?? Random();

  /// Resets the internal candy ID counter.
  void resetId() => _nextId = 0;

  /// Creates a full playable grid for a level.
  List<List<Candy?>> createInitialGrid(Level level) {
    final List<List<Candy?>> grid = List<List<Candy?>>.generate(
      level.gridRows,
      (_) => List<Candy?>.filled(level.gridCols, null),
    );
    fillEmptyCells(grid, level);
    return grid;
  }

  /// Fills every empty non-blocked cell with a new candy.
  void fillEmptyCells(List<List<Candy?>> grid, Level level) {
    for (int row = 0; row < level.gridRows; row++) {
      for (int col = 0; col < level.gridCols; col++) {
        if (level.isBlocked(row: row, col: col) || grid[row][col] != null) {
          continue;
        }
        // Spawn from above the grid for a smooth falling animation
        grid[row][col] = _newCandy(
          row: row,
          col: col,
          grid: grid,
          startingRow: -1,
        );
      }
    }
  }

  Candy _newCandy({
    required int row,
    required int col,
    required List<List<Candy?>> grid,
    int? startingRow,
  }) {
    for (int attempts = 0; attempts < 30; attempts++) {
      final CandyType type =
          CandyType.values[_random.nextInt(CandyType.values.length)];
      if (!_wouldMatch(row: row, col: col, type: type, grid: grid)) {
        return Candy(
          id: 'c${_nextId++}',
          type: type,
          row: startingRow ?? row,
          col: col,
        );
      }
    }
    return Candy(
      id: 'c${_nextId++}',
      type: CandyType.values[_random.nextInt(CandyType.values.length)],
      row: startingRow ?? row,
      col: col,
    );
  }

  bool _wouldMatch({
    required int row,
    required int col,
    required CandyType type,
    required List<List<Candy?>> grid,
  }) {
    final bool horizontal =
        col >= 2 &&
        grid[row][col - 1]?.type == type &&
        grid[row][col - 2]?.type == type;
    final bool vertical =
        row >= 2 &&
        grid[row - 1][col]?.type == type &&
        grid[row - 2][col]?.type == type;
    return horizontal || vertical;
  }
}
