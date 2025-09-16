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

  const GameState({
    required this.currentLevel,
    required this.gridSize,
    required this.colorNames,
    required this.ballCounts,
    required this.gridState,
    required this.path,
    required this.currentStep,
    required this.isGameOver,
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
    );
  }

  @override
  String toString() {
    return 'GameState(currentLevel: $currentLevel, gridSize: $gridSize, currentStep: $currentStep, isGameOver: $isGameOver)';
  }
}
