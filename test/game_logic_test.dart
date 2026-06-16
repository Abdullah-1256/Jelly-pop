import 'package:candy_crush/core/utils/audio_manager.dart';
import 'package:candy_crush/game/board/match_detector.dart';
import 'package:candy_crush/game/logic/special_candy_handler.dart';
import 'package:candy_crush/game/game_controller.dart';
import 'package:candy_crush/models/candy.dart';
import 'package:candy_crush/models/game_state.dart';
import 'package:candy_crush/models/level.dart';
import 'package:candy_crush/game/logic/score_calculator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _mockAudioChannels();
  test('match scoring follows the requested capped values', () {
    final ScoreCalculator calculator = ScoreCalculator();

    expect(calculator.matchScore(candyCount: 3, multiplier: 1), 20);
    expect(calculator.matchScore(candyCount: 4, multiplier: 1), 40);
    expect(calculator.matchScore(candyCount: 5, multiplier: 1), 60);
    expect(calculator.matchScore(candyCount: 3, multiplier: 2), 40);
    expect(calculator.specialScore(candyCount: 8, multiplier: 1), 100);
  });

  test('special candy creation follows 4 5 and 6 match rules', () {
    final MatchDetector detector = MatchDetector();

    final List<MatchGroup> fourMatch = detector.findMatches(
      _singleRowGrid(length: 4),
    );
    expect(fourMatch.single.special, SpecialType.stripedH);

    final List<MatchGroup> fiveMatch = detector.findMatches(
      _singleRowGrid(length: 5),
    );
    expect(fiveMatch.single.special, SpecialType.wrapped);

    final List<MatchGroup> sixMatch = detector.findMatches(
      _singleRowGrid(length: 6),
    );
    expect(sixMatch.single.special, SpecialType.colorBomb);
  });

  test('color bomb clears every candy matching the swapped color', () {
    final SpecialCandyHandler handler = SpecialCandyHandler();
    final Level level = _testLevel();
    final List<List<Candy?>> grid = _emptyGrid(level);
    grid[0][0] = _candy(0, 0, CandyType.purple, SpecialType.colorBomb);
    grid[0][1] = _candy(0, 1, CandyType.red);
    grid[1][1] = _candy(1, 1, CandyType.red);
    grid[2][2] = _candy(2, 2, CandyType.blue);

    final Set<BoardPoint> affected = handler.affectedCells(
      specialCandy: grid[0][0]!,
      swappedWith: grid[0][1],
      grid: grid,
      level: level,
    );

    expect(
      affected,
      containsAll(<BoardPoint>[(row: 0, col: 1), (row: 1, col: 1)]),
    );
    expect(affected, isNot(contains((row: 2, col: 2))));
  });

  test('booster blast settles board before the next manual swap', () async {
    MatchGameController? controller;
    _Move? move;
    final Level level = _testLevel();

    for (int attempt = 0; attempt < 8; attempt++) {
      final MatchGameController candidate = MatchGameController(_SilentAudio());
      await candidate.startLevel(level);
      await candidate.useHammer(3, 3);
      _expectSettledBoard(candidate, level);
      move = _findMove(candidate.state!.grid, level);
      if (move != null) {
        controller = candidate;
        break;
      }
    }

    expect(controller, isNotNull);
    expect(move, isNotNull);

    await controller!.attemptSwap(
      rowA: move!.rowA,
      colA: move.colA,
      rowB: move.rowB,
      colB: move.colB,
    );

    expect(controller.state!.phase, GamePhase.idle);
    _expectSettledBoard(controller, level);
  });
}

void _mockAudioChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers.global'),
        (MethodCall methodCall) async => null,
      );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (MethodCall methodCall) async => null,
      );
}

class _SilentAudio extends AudioManager {
  @override
  Future<void> playSfx(String asset) async {}

  @override
  Future<void> playSelectHaptic() async {}

  @override
  Future<void> playSwapHaptic() async {}

  @override
  Future<void> playMatchHaptic() async {}

  @override
  Future<void> playErrorHaptic() async {}

  @override
  Future<void> playComboHaptic() async {}
}

typedef _Move = ({int rowA, int colA, int rowB, int colB});

Level _testLevel() {
  return const Level(
    id: 99,
    moves: 50,
    targetScore: 999999,
    gridRows: 8,
    gridCols: 8,
    collectTargets: <CandyType, int>{},
    blockedCells: <String>{},
    starThreshold2: 999999,
    starThreshold3: 999999,
  );
}

List<List<Candy?>> _singleRowGrid({required int length}) {
  return <List<Candy?>>[
    List<Candy?>.generate(length, (int col) => _candy(0, col, CandyType.red)),
  ];
}

List<List<Candy?>> _emptyGrid(Level level) {
  return List<List<Candy?>>.generate(
    level.gridRows,
    (_) => List<Candy?>.filled(level.gridCols, null),
  );
}

Candy _candy(
  int row,
  int col,
  CandyType type, [
  SpecialType specialType = SpecialType.none,
]) {
  return Candy(
    id: '$row-$col-${type.name}-${specialType.name}',
    type: type,
    row: row,
    col: col,
    specialType: specialType,
  );
}

_Move? _findMove(List<List<Candy?>> grid, Level level) {
  for (int row = 0; row < level.gridRows; row++) {
    for (int col = 0; col < level.gridCols; col++) {
      if (col + 1 < level.gridCols) {
        final _Move move = (rowA: row, colA: col, rowB: row, colB: col + 1);
        if (_createsMatch(grid, move)) {
          return move;
        }
      }
      if (row + 1 < level.gridRows) {
        final _Move move = (rowA: row, colA: col, rowB: row + 1, colB: col);
        if (_createsMatch(grid, move)) {
          return move;
        }
      }
    }
  }
  return null;
}

bool _createsMatch(List<List<Candy?>> grid, _Move move) {
  final List<List<Candy?>> clone = _cloneGrid(grid);
  final Candy? first = clone[move.rowA][move.colA];
  final Candy? second = clone[move.rowB][move.colB];
  if (first == null || second == null) {
    return false;
  }
  clone[move.rowA][move.colA] = second.copyWith(row: move.rowA, col: move.colA);
  clone[move.rowB][move.colB] = first.copyWith(row: move.rowB, col: move.colB);
  return MatchDetector().findMatches(clone).isNotEmpty;
}

List<List<Candy?>> _cloneGrid(List<List<Candy?>> grid) {
  return List<List<Candy?>>.generate(grid.length, (int row) {
    return List<Candy?>.generate(grid[row].length, (int col) => grid[row][col]);
  });
}

void _expectSettledBoard(MatchGameController controller, Level level) {
  final GameState state = controller.state!;
  expect(state.phase, GamePhase.idle);
  for (int row = 0; row < level.gridRows; row++) {
    for (int col = 0; col < level.gridCols; col++) {
      final Candy? candy = state.grid[row][col];
      expect(candy, isNotNull, reason: 'cell $row,$col should be filled');
      expect(candy!.row, row, reason: 'cell $row,$col has wrong row');
      expect(candy.col, col, reason: 'cell $row,$col has wrong col');
    }
  }
}
