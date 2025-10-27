import 'cell_position.dart';

class GameState {
  final int currentLevel;
  final int gridSize;
  final List<String> colorNames;
  final Map<String, int> ballCounts;
  final List<List<String?>> gridState;
  final List<CellPosition> path;
  final int currentStep;
  final bool isGameOver;
  final List<GameStateSnapshot> history; // For undo functionality
  final Set<String> preFilledCells; // Track pre-filled cells like "row,col"

  const GameState({
    required this.currentLevel,
    required this.gridSize,
    required this.colorNames,
    required this.ballCounts,
    required this.gridState,
    required this.path,
    required this.currentStep,
    required this.isGameOver,
    this.history = const [],
    this.preFilledCells = const {},
  });

  GameState copyWith({
    int? currentLevel,
    int? gridSize,
    List<String>? colorNames,
    Map<String, int>? ballCounts,
    List<List<String?>>? gridState,
    List<CellPosition>? path,
    int? currentStep,
    bool? isGameOver,
    List<GameStateSnapshot>? history,
    Set<String>? preFilledCells,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      gridSize: gridSize ?? this.gridSize,
      colorNames: colorNames ?? this.colorNames,
      ballCounts: ballCounts ?? this.ballCounts,
      gridState: gridState ?? this.gridState,
      path: path ?? this.path,
      currentStep: currentStep ?? this.currentStep,
      isGameOver: isGameOver ?? this.isGameOver,
      history: history ?? this.history,
      preFilledCells: preFilledCells ?? this.preFilledCells,
    );
  }

  @override
  String toString() {
    return 'GameState(currentLevel: $currentLevel, gridSize: $gridSize, currentStep: $currentStep, isGameOver: $isGameOver)';
  }
}

class GameStateSnapshot {
  final List<List<String?>> gridState;
  final Map<String, int> ballCounts;
  final int currentStep;

  const GameStateSnapshot({
    required this.gridState,
    required this.ballCounts,
    required this.currentStep,
  });
}
