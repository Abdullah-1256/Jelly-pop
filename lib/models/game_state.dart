import 'candy.dart';

/// Current lifecycle phase of a playable board.
enum GamePhase { idle, swapping, resolving, won, lost }

/// Immutable state snapshot for the current level run.
class GameState {
  final List<List<Candy?>> grid;
  final int score;
  final int movesLeft;
  final GamePhase phase;
  final double comboMultiplier;
  final Map<CandyType, int> collectedTargets;
  final Map<String, CandyType> matchedCells;

  const GameState({
    required this.grid,
    required this.score,
    required this.movesLeft,
    required this.phase,
    required this.comboMultiplier,
    required this.collectedTargets,
    required this.matchedCells,
  });

  /// Creates an empty starting state for a level.
  factory GameState.initial({
    required List<List<Candy?>> grid,
    required int moves,
  }) {
    return GameState(
      grid: grid,
      score: 0,
      movesLeft: moves,
      phase: GamePhase.idle,
      comboMultiplier: 1,
      collectedTargets: const <CandyType, int>{},
      matchedCells: const <String, CandyType>{},
    );
  }

  /// Creates a copy with changed fields.
  GameState copyWith({
    List<List<Candy?>>? grid,
    int? score,
    int? movesLeft,
    GamePhase? phase,
    double? comboMultiplier,
    Map<CandyType, int>? collectedTargets,
    Map<String, CandyType>? matchedCells,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      movesLeft: movesLeft ?? this.movesLeft,
      phase: phase ?? this.phase,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      collectedTargets: collectedTargets ?? this.collectedTargets,
      matchedCells: matchedCells ?? this.matchedCells,
    );
  }
}
