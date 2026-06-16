/// Candy colors available on the game board.
enum CandyType { red, blue, green, yellow, purple, orange }

/// Special candy power types created by larger matches.
enum SpecialType { none, stripedH, stripedV, wrapped, colorBomb }

/// Visual state used by board animation widgets.
enum CandyState { normal, matched, falling, spawning, selected, hint }

/// Immutable candy model stored in the board grid.
class Candy {
  final String id;
  final CandyType type;
  final SpecialType specialType;
  final CandyState state;
  final int row;
  final int col;

  const Candy({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.specialType = SpecialType.none,
    this.state = CandyState.normal,
  });

  /// Builds a candy model from saved JSON.
  factory Candy.fromJson(Map<String, Object?> json) {
    return Candy(
      id: json['id'] as String,
      type: CandyType.values.byName(json['type'] as String),
      specialType: SpecialType.values.byName(json['special_type'] as String),
      state: CandyState.values.byName(json['state'] as String),
      row: json['row'] as int,
      col: json['col'] as int,
    );
  }

  /// Converts this candy to serializable JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'type': type.name,
      'special_type': specialType.name,
      'state': state.name,
      'row': row,
      'col': col,
    };
  }

  /// Creates a copy with changed fields.
  Candy copyWith({
    String? id,
    CandyType? type,
    SpecialType? specialType,
    CandyState? state,
    int? row,
    int? col,
  }) {
    return Candy(
      id: id ?? this.id,
      type: type ?? this.type,
      specialType: specialType ?? this.specialType,
      state: state ?? this.state,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}
