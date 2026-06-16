import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/audio_manager.dart';
import '../models/candy.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import 'board/board_filler.dart';
import 'board/board_model.dart';
import 'board/gravity_handler.dart';
import 'board/match_detector.dart';
import 'logic/level_checker.dart';
import 'logic/score_calculator.dart';
import 'logic/special_candy_handler.dart';
import 'logic/swap_validator.dart';

/// Orchestrates moves, matches, cascades, scoring, and level completion.
class MatchGameController extends ChangeNotifier {
  final AudioManager _audioManager;
  final BoardFiller _filler = BoardFiller();
  final MatchDetector _detector = MatchDetector();
  final GravityHandler _gravity = GravityHandler();
  final SwapValidator _swapValidator = SwapValidator();
  final ScoreCalculator _scoreCalculator = ScoreCalculator();
  final SpecialCandyHandler _specialHandler = SpecialCandyHandler();
  final LevelChecker _levelChecker = LevelChecker();

  Level? _level;
  GameState? _state;
  BoardPoint? _selectedPoint;
  Set<String> _swappingCandyIds = <String>{};
  List<BoardPoint>? _hintPoints;
  Timer? _idleTimer;
  int _stars = 0;
  int _lastScorePopup = 0;
  String _comboText = '';
  int _generation = 0;

  MatchGameController(this._audioManager);

  /// Properly dispose of all resources (called when GameProvider is disposed).
  @override
  void dispose() {
    _stopIdleTimer();
    super.dispose();
  }

  /// Returns the active level configuration.
  Level? get level => _level;

  /// Returns the current immutable gameplay state.
  GameState? get state => _state;

  /// Returns the currently selected candy coordinate.
  BoardPoint? get selectedPoint => _selectedPoint;

  /// Returns the points currently being hinted.
  List<BoardPoint>? get hintPoints => _hintPoints;

  /// Returns IDs of candies currently being swapped.
  Set<String> get swappingCandyIds => _swappingCandyIds;

  /// Returns the stars earned after a win.
  int get stars => _stars;

  /// Returns the most recent floating score amount.
  int get lastScorePopup => _lastScorePopup;

  /// Returns combo celebration text for the current cascade.
  String get comboText => _comboText;

  /// Starts or restarts a level with a fresh board.
  Future<void> startLevel(Level level) async {
    _generation++;
    final int currentGen = _generation;

    _level = level;
    _stars = 0;
    _lastScorePopup = 0;
    _comboText = '';
    _selectedPoint = null;
    _hintPoints = null;
    _filler.resetId(); // Fix duplicate key potential

    final List<List<Candy?>> grid = _filler.createInitialGrid(level);

    // First state update: Grid full of candies at row -1
    _state = GameState.initial(grid: grid, moves: level.moves);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_generation != currentGen) return;

    // Second state update: Update all candies to their target rows to trigger fall-in
    _finishRefillPositions(grid);
    _state = _state!.copyWith(grid: _clone(grid));
    notifyListeners();

    _resetIdleTimer();
  }

  /// Selects a cell or swaps with the previous adjacent selection.
  Future<void> selectCell({required int row, required int col}) async {
    _resetIdleTimer();
    final BoardPoint? previous = _selectedPoint;
    if (previous == null) {
      _selectedPoint = (row: row, col: col);
      notifyListeners();
      await _audioManager.playSelectHaptic();
      return;
    }
    if (previous.row == row && previous.col == col) {
      _selectedPoint = null;
      notifyListeners();
      return;
    }
    await attemptSwap(
      rowA: previous.row,
      colA: previous.col,
      rowB: row,
      colB: col,
    );
  }

  /// Converts a swipe direction into a board swap.
  Future<void> swipeFrom({
    required int row,
    required int col,
    required int rowDelta,
    required int colDelta,
  }) async {
    await attemptSwap(
      rowA: row,
      colA: col,
      rowB: row + rowDelta,
      colB: col + colDelta,
    );
  }

  /// Attempts a swap, resolves matches, and checks level outcome.
  Future<bool> attemptSwap({
    required int rowA,
    required int colA,
    required int rowB,
    required int colB,
  }) async {
    _resetIdleTimer();
    final Level? activeLevel = _level;
    final GameState? activeState = _state;
    final int currentGen = _generation;

    if (activeLevel == null ||
        activeState == null ||
        activeState.phase != GamePhase.idle) {
      return false;
    }
    if (_hasUnsettledCells(activeState.grid, activeLevel)) {
      await _repairActiveBoard(activeState, activeLevel);
      return false;
    }
    if (!_swapValidator.canSwap(
      level: activeLevel,
      rowA: rowA,
      colA: colA,
      rowB: rowB,
      colB: colB,
    )) {
      _selectedPoint = null;
      notifyListeners();
      await _audioManager.playErrorHaptic();
      return false;
    }
    final BoardModel board = BoardModel.fromLevel(
      activeLevel,
      _clone(activeState.grid),
    );
    board.swap(rowA: rowA, colA: colA, rowB: rowB, colB: colB);
    final Candy? candyA = activeState.grid[rowA][colA];
    final Candy? candyB = activeState.grid[rowB][colB];
    if (candyA != null && candyB != null) {
      _swappingCandyIds = <String>{candyA.id, candyB.id};
    }
    _selectedPoint = null;
    _state = activeState.copyWith(
      grid: board.cloneGrid(),
      phase: GamePhase.swapping,
    );
    notifyListeners();
    await _audioManager.playSwapHaptic();
    unawaited(_audioManager.playSfx(AppStrings.audioSwap));
    await Future<void>.delayed(const Duration(milliseconds: AppSizes.swapMs));
    if (_generation != currentGen) return false;

    _swappingCandyIds = <String>{};
    notifyListeners();

    final Candy? first = board.grid[rowA][colA];
    final Candy? second = board.grid[rowB][colB];
    final bool activatedSpecial = await _activateSpecialIfNeeded(
      board,
      activeLevel,
      first,
      second,
    );
    if (_generation != currentGen) return true;

    if (activatedSpecial) {
      await _finishMove(board, activeLevel);
      return true;
    }

    final List<MatchGroup> matches = _detector.findMatches(
      board.grid,
      preferredOrigin: (row: rowB, col: colB),
    );
    if (matches.isEmpty) {
      await _audioManager.playErrorHaptic();
      board.swap(rowA: rowA, colA: colA, rowB: rowB, colB: colB);
      _state = activeState.copyWith(
        grid: board.cloneGrid(),
        phase: GamePhase.idle,
      );
      notifyListeners();
      return false;
    }
    _state = _state!.copyWith(
      movesLeft: _state!.movesLeft - 1,
      phase: GamePhase.resolving,
    );
    notifyListeners();
    await _resolveMatches(board, activeLevel, matches);
    if (_generation != currentGen) return true;

    await _finishMove(board, activeLevel);
    return true;
  }

  Future<bool> _activateSpecialIfNeeded(
    BoardModel board,
    Level level,
    Candy? first,
    Candy? second,
  ) async {
    final int currentGen = _generation;
    final Set<BoardPoint> affected = <BoardPoint>{};
    if (first != null && first.specialType != SpecialType.none) {
      affected.addAll(
        _specialHandler.affectedCells(
          specialCandy: first,
          swappedWith: second,
          grid: board.grid,
          level: level,
        ),
      );
    }
    if (second != null && second.specialType != SpecialType.none) {
      affected.addAll(
        _specialHandler.affectedCells(
          specialCandy: second,
          swappedWith: first,
          grid: board.grid,
          level: level,
        ),
      );
    }
    if (affected.isEmpty) {
      return false;
    }
    final Map<String, CandyType> affectedTypes = _cellTypes(board, affected);

    // Count each unique candy type affected by the blast as 1 collection event
    final Map<CandyType, int> collected = <CandyType, int>{
      ..._state!.collectedTargets,
    };
    final Set<CandyType> uniqueTypes = affectedTypes.values.toSet();
    for (final CandyType type in uniqueTypes) {
      collected[type] = (collected[type] ?? 0) + 1;
    }

    _state = _state!.copyWith(
      movesLeft: _state!.movesLeft - 1,
      phase: GamePhase.resolving,
      matchedCells: affectedTypes,
      collectedTargets: collected,
    );
    notifyListeners();
    unawaited(_audioManager.playComboHaptic());
    unawaited(_audioManager.playSfx(AppStrings.audioSpecial));
    final int score = _scoreCalculator.specialScore(
      candyCount: affected.length,
      multiplier: _state!.comboMultiplier,
    );
    _removeCells(board, affected, keepSpecialOrigin: null);
    _addScore(score);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_generation != currentGen) return true;

    await _settleBoard(board, level);
    return true;
  }

  Future<void> _resolveMatches(
    BoardModel board,
    Level level,
    List<MatchGroup> initialMatches,
  ) async {
    final int currentGen = _generation;
    List<MatchGroup> matches = initialMatches;
    double multiplier = 1;
    while (matches.isNotEmpty) {
      final Map<String, CandyType> matchedCells = _matchCells(board, matches);
      int score = 0;
      for (final MatchGroup group in matches) {
        score += _scoreCalculator.matchScore(
          candyCount: group.cells.length,
          multiplier: multiplier,
        );
        _removeGroup(board, group);
      }
      _addScore(score.clamp(0, 200).toInt());
      _comboText = _comboFor(multiplier);
      if (multiplier > 1) {
        unawaited(_audioManager.playComboHaptic());
      } else {
        await _audioManager.playMatchHaptic();
      }
      unawaited(_audioManager.playSfx(
        multiplier > 1 ? AppStrings.audioCascade : AppStrings.audioMatch,
      ));
      _state = _state!.copyWith(
        grid: board.cloneGrid(),
        comboMultiplier: multiplier,
        matchedCells: matchedCells,
      );
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: AppSizes.popMs));
      if (_generation != currentGen) return;

      await _settleBoard(board, level);
      if (_generation != currentGen) return;

      multiplier = min(AppSizes.maxComboMultiplier, multiplier + 0.5);
      matches = _detector.findMatches(board.grid);
    }
  }

  Future<void> _finishMove(BoardModel board, Level level) async {
    _comboText = '';
    final GameState current = _state!.copyWith(
      grid: board.cloneGrid(),
      phase: GamePhase.idle,
      comboMultiplier: 1,
      matchedCells: const <String, CandyType>{},
    );
    if (_levelChecker.isWin(current, level)) {
      _stopIdleTimer(); // Ensure timer is stopped
      _hintPoints = null; // Clear hints
      _selectedPoint = null; // Clear selection
      _swappingCandyIds.clear(); // Clear swap state
      _stars = _levelChecker.starsForScore(score: current.score, level: level);
      _state = current.copyWith(phase: GamePhase.won);
      unawaited(_audioManager.playSfx(AppStrings.audioWin));
    } else if (_levelChecker.isLose(current, level)) {
      _stopIdleTimer(); // Ensure timer is stopped
      _hintPoints = null; // Clear hints
      _selectedPoint = null; // Clear selection
      _swappingCandyIds.clear(); // Clear swap state
      _state = current.copyWith(phase: GamePhase.lost);
      unawaited(_audioManager.playSfx(AppStrings.audioLose));
    } else {
      _state = current;
      _resetIdleTimer();
    }
    notifyListeners();
  }

  Map<String, CandyType> _matchCells(
    BoardModel board,
    List<MatchGroup> matches,
  ) {
    return _cellTypes(
      board,
      matches.expand((MatchGroup group) => group.cells).toSet(),
    );
  }

  Map<String, CandyType> _cellTypes(BoardModel board, Set<BoardPoint> cells) {
    final Map<String, CandyType> result = <String, CandyType>{};
    for (final BoardPoint point in cells) {
      final Candy? candy = board.grid[point.row][point.col];
      if (candy == null) {
        continue;
      }
      result['${point.row},${point.col}'] = candy.type;
    }
    return result;
  }

  void _removeGroup(BoardModel board, MatchGroup group) {
    final Candy? originCandy = board.grid[group.origin.row][group.origin.col];

    // Increment collection count by 1 for the match group (1 match = 1 point)
    if (originCandy != null) {
      final Map<CandyType, int> collected = <CandyType, int>{
        ..._state!.collectedTargets,
      };
      collected[originCandy.type] = (collected[originCandy.type] ?? 0) + 1;
      _state = _state!.copyWith(collectedTargets: collected);
    }

    final BoardPoint? keepOrigin = group.special == SpecialType.none
        ? null
        : group.origin;
    _removeCells(board, group.cells.toSet(), keepSpecialOrigin: keepOrigin);
    if (keepOrigin != null && originCandy != null) {
      final CandyType type = group.special == SpecialType.colorBomb
          ? CandyType.purple
          : originCandy.type;
      board.grid[keepOrigin.row][keepOrigin.col] = originCandy.copyWith(
        type: type,
        specialType: group.special,
        row: keepOrigin.row,
        col: keepOrigin.col,
      );
    }
  }

  void _removeCells(
    BoardModel board,
    Set<BoardPoint> cells, {
    BoardPoint? keepSpecialOrigin,
  }) {
    for (final BoardPoint point in cells) {
      if (keepSpecialOrigin != null && point == keepSpecialOrigin) {
        continue;
      }
      board.grid[point.row][point.col] = null;
    }
  }

  void _addScore(int amount) {
    _lastScorePopup = amount;
    _state = _state!.copyWith(score: _state!.score + amount);
  }

  String _comboFor(double multiplier) {
    if (multiplier >= 3) {
      return AppStrings.amazing;
    }
    if (multiplier >= 2) {
      return AppStrings.delicious;
    }
    if (multiplier > 1) {
      return AppStrings.sweet;
    }
    return '';
  }

  void _resetIdleTimer() {
    _stopIdleTimer();
    _hintPoints = null;
    _idleTimer = Timer(const Duration(seconds: AppSizes.idleHintSeconds), () {
      _hintPoints = _findHint();
      notifyListeners();
    });
  }

  void _stopIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  List<BoardPoint>? _findHint() {
    final GameState? activeState = _state;
    final Level? activeLevel = _level;
    if (activeState == null || activeLevel == null) {
      return null;
    }

    final int rows = activeLevel.gridRows;
    final int cols = activeLevel.gridCols;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Try horizontal swap
        if (c + 1 < cols) {
          if (_canMove(r, c, r, c + 1, activeLevel, activeState)) {
            return [(row: r, col: c), (row: r, col: c + 1)];
          }
        }
        // Try vertical swap
        if (r + 1 < rows) {
          if (_canMove(r, c, r + 1, c, activeLevel, activeState)) {
            return [(row: r, col: c), (row: r + 1, col: c)];
          }
        }
      }
    }
    return null;
  }

  bool _canMove(int rA, int cA, int rB, int cB, Level level, GameState state) {
    if (!_swapValidator.canSwap(
      level: level,
      rowA: rA,
      colA: cA,
      rowB: rB,
      colB: cB,
    )) {
      return false;
    }

    final List<List<Candy?>> grid = _clone(state.grid);
    final Candy? a = grid[rA][cA];
    final Candy? b = grid[rB][cB];
    grid[rA][cA] = b;
    grid[rB][cB] = a;

    return _detector.findMatches(grid).isNotEmpty;
  }

  /// Adds extra moves to the current state and resumes idle phase.
  void addExtraMoves(int count) {
    if (_state == null) {
      return;
    }
    _state = _state!.copyWith(
      movesLeft: _state!.movesLeft + count,
      phase: GamePhase.idle,
    );
    notifyListeners();
  }

  /// Uses the Hammer booster to blast Row [row] and Col [col] (2 lines).
  Future<void> useHammer(int row, int col) async {
    final GameState? activeState = _state;
    if (activeState == null || activeState.phase != GamePhase.idle) return;

    final List<BoardPoint> affected = [];
    final Map<String, CandyType> affectedTypes = {};

    // Clear Row [row]
    for (int c = 0; c < activeState.grid[row].length; c++) {
      final Candy? candy = activeState.grid[row][c];
      if (candy != null) {
        affected.add((row: row, col: c));
        affectedTypes['$row,$c'] = candy.type;
      }
    }
    // Clear Column [col]
    for (int r = 0; r < activeState.grid.length; r++) {
      if (r == row) continue; // Already added
      final Candy? candy = activeState.grid[r][col];
      if (candy != null) {
        affected.add((row: r, col: col));
        affectedTypes['$r,$col'] = candy.type;
      }
    }

    await _performBoosterBlast(affected, affectedTypes);
  }

  /// Uses the Rocket booster to blast 3 rows around the area (r-1 to r+1).
  Future<void> useRocket(int row, int col) async {
    final GameState? activeState = _state;
    if (activeState == null || activeState.phase != GamePhase.idle) return;

    final List<BoardPoint> affected = [];
    final Map<String, CandyType> affectedTypes = {};

    for (int r = row - 1; r <= row + 1; r++) {
      if (r < 0 || r >= activeState.grid.length) continue;
      for (int c = 0; c < activeState.grid[r].length; c++) {
        final Candy? candy = activeState.grid[r][c];
        if (candy != null) {
          affected.add((row: r, col: c));
          affectedTypes['$r,$c'] = candy.type;
        }
      }
    }

    await _performBoosterBlast(affected, affectedTypes);
  }

  /// Uses the Bomb booster to blast 5 rows around the area (r-2 to r+2).
  Future<void> useBomb(int row, int col) async {
    final GameState? activeState = _state;
    if (activeState == null || activeState.phase != GamePhase.idle) return;

    final List<BoardPoint> affected = [];
    final Map<String, CandyType> affectedTypes = {};

    for (int r = row - 2; r <= row + 2; r++) {
      if (r < 0 || r >= activeState.grid.length) continue;
      for (int c = 0; c < activeState.grid[r].length; c++) {
        final Candy? candy = activeState.grid[r][c];
        if (candy != null) {
          affected.add((row: r, col: c));
          affectedTypes['$r,$c'] = candy.type;
        }
      }
    }

    await _performBoosterBlast(affected, affectedTypes);
  }

  /// Uses the Starter Pack to blast all available candies on the board.
  Future<void> useStarterPack() async {
    final GameState? activeState = _state;
    if (activeState == null || activeState.phase != GamePhase.idle) return;

    final List<BoardPoint> affected = [];
    final Map<String, CandyType> affectedTypes = {};

    for (int r = 0; r < activeState.grid.length; r++) {
      for (int c = 0; c < activeState.grid[r].length; c++) {
        final Candy? candy = activeState.grid[r][c];
        if (candy != null) {
          affected.add((row: r, col: c));
          affectedTypes['$r,$c'] = candy.type;
        }
      }
    }

    await _performBoosterBlast(affected, affectedTypes);
  }

  Future<void> _performBoosterBlast(
    List<BoardPoint> affected,
    Map<String, CandyType> affectedTypes,
  ) async {
    final int currentGen = _generation;
    final BoardModel board = BoardModel.fromLevel(
      _level!,
      _clone(_state!.grid),
    );
    _selectedPoint = null;
    _hintPoints = null;
    _swappingCandyIds = <String>{};

    _state = _state!.copyWith(
      phase: GamePhase.resolving,
      matchedCells: affectedTypes,
    );
    notifyListeners();

    unawaited(_audioManager.playComboHaptic());
    unawaited(_audioManager.playSfx(AppStrings.audioSpecial));
    await Future<void>.delayed(const Duration(milliseconds: AppSizes.popMs));
    if (_generation != currentGen) return;

    for (final point in affected) {
      board.grid[point.row][point.col] = null;
    }
    _addScore(affected.length * 20);

    await _resolveBoard(board, _level!);
  }

  /// Internal logic to cascade and fill after a booster or move.
  Future<void> _resolveBoard(BoardModel board, Level level) async {
    final int currentGen = _generation;
    int safetyCounter = 0;
    while (safetyCounter < 50) {
      safetyCounter++;
      if (_hasUnsettledCells(board.grid, level)) {
        await _settleBoard(board, level);
        if (_generation != currentGen) return;
        continue;
      }

      final List<MatchGroup> matches = _detector.findMatches(board.grid);

      if (matches.isNotEmpty) {
        // 1. Process matches
        final Map<String, CandyType> matchesMap = _matchCells(board, matches);
        for (final MatchGroup match in matches) {
          _removeGroup(board, match);
          _addScore(
            _scoreCalculator.matchScore(
              candyCount: match.cells.length,
              multiplier: _state!.comboMultiplier,
            ),
          );
        }

        final double nextMult = min(
          AppSizes.maxComboMultiplier,
          _state!.comboMultiplier + 0.5,
        );
        _comboText = _comboFor(nextMult);
        _state = _state!.copyWith(
          grid: board.cloneGrid(),
          matchedCells: matchesMap,
          comboMultiplier: nextMult,
        );
        if (nextMult > 1) {
          unawaited(_audioManager.playComboHaptic());
        } else {
          await _audioManager.playMatchHaptic();
        }
        notifyListeners();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (_generation != currentGen) return;

        // Clear blast effects
        _state = _state!.copyWith(matchedCells: const {});
        notifyListeners();
        continue;
      }

      break;
    }
    await _finishMove(board, level);
  }

  Future<void> _repairActiveBoard(GameState state, Level level) async {
    final int currentGen = _generation;
    final BoardModel board = BoardModel.fromLevel(level, _clone(state.grid));
    _state = state.copyWith(phase: GamePhase.resolving);
    notifyListeners();
    await _settleBoard(board, level);
    if (_generation != currentGen) return;
    await _finishMove(board, level);
  }

  Future<void> _settleBoard(BoardModel board, Level level) async {
    final int currentGen = _generation;
    final List<MovementRecord> movements = _gravity.applyGravity(
      board.grid,
      level,
    );
    if (movements.isNotEmpty) {
      _state = _state!.copyWith(
        grid: board.cloneGrid(),
        matchedCells: const <String, CandyType>{},
      );
      notifyListeners();
      await Future<void>.delayed(
        const Duration(milliseconds: AppSizes.fallMinMs),
      );
      if (_generation != currentGen) return;
    }
    if (_performRefill(board, level)) {
      _state = _state!.copyWith(
        grid: board.cloneGrid(),
        matchedCells: const <String, CandyType>{},
      );
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      if (_generation != currentGen) return;
    }
    _finishRefillPositions(board.grid);
    _state = _state!.copyWith(
      grid: board.cloneGrid(),
      matchedCells: const <String, CandyType>{},
    );
    notifyListeners();
    await Future<void>.delayed(
      const Duration(milliseconds: AppSizes.fallMinMs),
    );
  }

  bool _performRefill(BoardModel board, Level level) {
    for (int row = 0; row < level.gridRows; row++) {
      for (int col = 0; col < level.gridCols; col++) {
        if (level.isBlocked(row: row, col: col) ||
            board.grid[row][col] != null) {
          continue;
        }
        _filler.fillEmptyCells(board.grid, level);
        return true;
      }
    }
    return false;
  }

  void _finishRefillPositions(List<List<Candy?>> grid) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final Candy? candy = grid[r][c];
        if (candy != null && (candy.row != r || candy.col != c)) {
          grid[r][c] = candy.copyWith(row: r, col: c);
        }
      }
    }
  }

  bool _hasUnsettledCells(List<List<Candy?>> grid, Level level) {
    for (int row = 0; row < level.gridRows; row++) {
      for (int col = 0; col < level.gridCols; col++) {
        if (level.isBlocked(row: row, col: col)) {
          continue;
        }
        final Candy? candy = grid[row][col];
        if (candy == null || candy.row != row || candy.col != col) {
          return true;
        }
      }
    }
    return false;
  }

  List<List<Candy?>> _clone(List<List<Candy?>> grid) {
    return List<List<Candy?>>.generate(grid.length, (int row) {
      return List<Candy?>.generate(
        grid[row].length,
        (int col) => grid[row][col],
      );
    });
  }
}
