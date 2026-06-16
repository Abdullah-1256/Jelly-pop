import '../../models/candy.dart';

typedef BoardPoint = ({int row, int col});
typedef MatchGroup = ({
  List<BoardPoint> cells,
  SpecialType special,
  BoardPoint origin,
});

/// Detects line, five-candy, and L/T shape matches on the board.
class MatchDetector {
  /// Finds all matches in the supplied grid.
  List<MatchGroup> findMatches(
    List<List<Candy?>> grid, {
    BoardPoint? preferredOrigin,
  }) {
    final List<Set<String>> groups = <Set<String>>[];
    final Map<String, SpecialType> specialHints = <String, SpecialType>{};
    _scanRows(grid, groups, specialHints);
    _scanCols(grid, groups, specialHints);
    final List<Set<String>> merged = _merge(groups);
    return merged.map((Set<String> keys) {
      final List<BoardPoint> cells = keys.map(_decode).toList();
      final BoardPoint origin = _originFor(cells, preferredOrigin);
      return (
        cells: cells,
        special: _specialFor(cells, specialHints),
        origin: origin,
      );
    }).toList();
  }

  void _scanRows(
    List<List<Candy?>> grid,
    List<Set<String>> groups,
    Map<String, SpecialType> hints,
  ) {
    for (int row = 0; row < grid.length; row++) {
      int start = 0;
      while (start < grid[row].length) {
        final Candy? candy = grid[row][start];
        if (candy == null) {
          start++;
          continue;
        }
        int end = start + 1;
        while (end < grid[row].length && grid[row][end]?.type == candy.type) {
          end++;
        }
        _addLine(row, start, end, true, groups, hints);
        start = end;
      }
    }
  }

  void _scanCols(
    List<List<Candy?>> grid,
    List<Set<String>> groups,
    Map<String, SpecialType> hints,
  ) {
    for (int col = 0; col < grid.first.length; col++) {
      int start = 0;
      while (start < grid.length) {
        final Candy? candy = grid[start][col];
        if (candy == null) {
          start++;
          continue;
        }
        int end = start + 1;
        while (end < grid.length && grid[end][col]?.type == candy.type) {
          end++;
        }
        _addLine(col, start, end, false, groups, hints);
        start = end;
      }
    }
  }

  void _addLine(
    int fixed,
    int start,
    int end,
    bool horizontal,
    List<Set<String>> groups,
    Map<String, SpecialType> hints,
  ) {
    final int length = end - start;
    if (length < 3) {
      return;
    }
    final Set<String> line = <String>{};
    for (int index = start; index < end; index++) {
      line.add(horizontal ? '$fixed,$index' : '$index,$fixed');
    }
    if (length >= 6) {
      for (final String key in line) {
        hints[key] = SpecialType.colorBomb;
      }
    } else if (length == 5) {
      for (final String key in line) {
        hints[key] = SpecialType.wrapped;
      }
    } else if (length == 4) {
      final SpecialType type = horizontal
          ? SpecialType.stripedH
          : SpecialType.stripedV;
      for (final String key in line) {
        hints[key] = type;
      }
    }
    groups.add(line);
  }

  List<Set<String>> _merge(List<Set<String>> groups) {
    final List<Set<String>> output = groups
        .map((Set<String> g) => <String>{...g})
        .toList();
    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < output.length; i++) {
        for (int j = i + 1; j < output.length; j++) {
          if (output[i].intersection(output[j]).isNotEmpty) {
            output[i].addAll(output[j]);
            output.removeAt(j);
            changed = true;
            break;
          }
        }
        if (changed) {
          break;
        }
      }
    }
    return output;
  }

  SpecialType _specialFor(
    List<BoardPoint> cells,
    Map<String, SpecialType> hints,
  ) {
    final Set<int> rows = cells.map((BoardPoint point) => point.row).toSet();
    final Set<int> cols = cells.map((BoardPoint point) => point.col).toSet();
    if (cells.length >= 6 ||
        cells.any(
          (BoardPoint point) => hints[_encode(point)] == SpecialType.colorBomb,
        )) {
      return SpecialType.colorBomb;
    }
    if (cells.length >= 5 || rows.length > 1 && cols.length > 1) {
      return SpecialType.wrapped;
    }
    return cells
            .map((BoardPoint point) => hints[_encode(point)])
            .firstWhere(
              (SpecialType? type) => type != null,
              orElse: () => SpecialType.none,
            ) ??
        SpecialType.none;
  }

  BoardPoint _originFor(List<BoardPoint> cells, BoardPoint? preferred) {
    if (preferred != null &&
        cells.any((BoardPoint point) => point == preferred)) {
      return preferred;
    }
    return cells[cells.length ~/ 2];
  }

  String _encode(BoardPoint point) => '${point.row},${point.col}';

  BoardPoint _decode(String key) {
    final List<String> parts = key.split(',');
    return (row: int.parse(parts.first), col: int.parse(parts.last));
  }
}
