import '../../models/candy.dart';
import '../../models/level.dart';

/// Mutable board container used internally by game logic.
class BoardModel {
  final int rows;
  final int cols;
  final List<List<Candy?>> grid;

  BoardModel({required this.rows, required this.cols, required this.grid});

  /// Creates a board wrapper from a level and grid.
  factory BoardModel.fromLevel(Level level, List<List<Candy?>> grid) {
    return BoardModel(rows: level.gridRows, cols: level.gridCols, grid: grid);
  }

  /// Returns a safe clone of the current grid.
  List<List<Candy?>> cloneGrid() {
    return List<List<Candy?>>.generate(rows, (int row) {
      return List<Candy?>.generate(cols, (int col) => grid[row][col]);
    });
  }

  /// Swaps two candy positions and updates their coordinates.
  void swap({
    required int rowA,
    required int colA,
    required int rowB,
    required int colB,
  }) {
    final Candy? first = grid[rowA][colA];
    final Candy? second = grid[rowB][colB];
    grid[rowA][colA] = second?.copyWith(row: rowA, col: colA);
    grid[rowB][colB] = first?.copyWith(row: rowB, col: colB);
  }
}
