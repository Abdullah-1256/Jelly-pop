import '../../models/level.dart';

/// Validates board swap attempts before they mutate state.
class SwapValidator {
  /// Returns true when both cells are in bounds, unblocked, and adjacent.
  bool canSwap({
    required Level level,
    required int rowA,
    required int colA,
    required int rowB,
    required int colB,
  }) {
    final bool inBounds =
        rowA >= 0 &&
        rowB >= 0 &&
        colA >= 0 &&
        colB >= 0 &&
        rowA < level.gridRows &&
        rowB < level.gridRows &&
        colA < level.gridCols &&
        colB < level.gridCols;
    final int distance = (rowA - rowB).abs() + (colA - colB).abs();
    return inBounds &&
        distance == 1 &&
        !level.isBlocked(row: rowA, col: colA) &&
        !level.isBlocked(row: rowB, col: colB);
  }
}
