import '../models/cell_position.dart';
import '../models/game_state.dart';
import '../constants/app_constants.dart';

class GameLogicService {
  static List<CellPosition> generateSnakePath(int gridSize) {
    final path = <CellPosition>[];
    for (int row = 0; row < gridSize; row++) {
      if (row % 2 == 0) { // Left-to-right
        for (int col = 0; col < gridSize; col++) {
          path.add(CellPosition(row, col));
        }
      } else { // Right-to-left
        for (int col = gridSize - 1; col >= 0; col--) {
          path.add(CellPosition(row, col));
        }
      }
    }
    return path;
  }

  static bool isPlacementValid(
    List<List<String?>> gridState,
    int row,
    int col,
    String color,
    int gridSize,
  ) {
    // Check 8 adjacent neighbors
    for (int rOff = -1; rOff <= 1; rOff++) {
      for (int cOff = -1; cOff <= 1; cOff++) {
        if (rOff == 0 && cOff == 0) continue;
        int checkRow = row + rOff;
        int checkCol = col + cOff;
        if (checkRow >= 0 && checkRow < gridSize && checkCol >= 0 && checkCol < gridSize) {
          if (gridState[checkRow][checkCol] == color) return false;
        }
      }
    }
    
    // Check row
    for (int c = 0; c < gridSize; c++) {
      if (gridState[row][c] == color) return false;
    }
    
    // Check column
    for (int r = 0; r < gridSize; r++) {
      if (gridState[r][col] == color) return false;
    }
    
    return true;
  }

  static Set<String> getInvalidColorsForNextStep(
    List<List<String?>> gridState,
    List<CellPosition> path,
    int currentStep,
    int gridSize,
  ) {
    if (currentStep >= path.length) return {};

    final pos = path[currentStep];
    final usedColors = <String>{};

    // Check adjacent cells
    for (int rOff = -1; rOff <= 1; rOff++) {
      for (int cOff = -1; cOff <= 1; cOff++) {
        if (rOff == 0 && cOff == 0) continue;
        int checkRow = pos.row + rOff;
        int checkCol = pos.col + cOff;
        if (checkRow >= 0 && checkRow < gridSize && checkCol >= 0 && checkCol < gridSize) {
          final color = gridState[checkRow][checkCol];
          if (color != null) usedColors.add(color);
        }
      }
    }
    
    // Check row
    for (int c = 0; c < gridSize; c++) {
      final color = gridState[pos.row][c];
      if (color != null) usedColors.add(color);
    }
    
    // Check column
    for (int r = 0; r < gridSize; r++) {
      final color = gridState[r][pos.col];
      if (color != null) usedColors.add(color);
    }
    
    return usedColors;
  }

  static bool checkIfAllBallsBlocked(
    List<String> colorNames,
    Map<String, int> ballCounts,
    List<List<String?>> gridState,
    List<CellPosition> path,
    int currentStep,
    int gridSize,
  ) {
    final invalidColors = getInvalidColorsForNextStep(gridState, path, currentStep, gridSize);
    final availableColors = colorNames.where((c) =>
        ballCounts[c]! > 0 && !invalidColors.contains(c)
    );
    return availableColors.isEmpty;
  }

  static GameState initializeGame(int levelIndex) {
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) {
      throw ArgumentError('Invalid level index: $levelIndex');
    }

    final config = AppConstants.levelConfig[levelIndex];
    final gridSize = config['gridSize'] as int;
    final colorNames = List<String>.from(config['colors'] as List);
    final ballCounts = {for (var name in colorNames) name: gridSize};
    final gridState = List.generate(gridSize, (_) => List.filled(gridSize, null));
    final path = generateSnakePath(gridSize);

    return GameState(
      currentLevel: levelIndex,
      gridSize: gridSize,
      colorNames: colorNames,
      ballCounts: ballCounts,
      gridState: gridState,
      path: path,
      currentStep: 0,
      isGameOver: false,
    );
  }

  static GameState placeBall(
    GameState currentState,
    String color,
  ) {
    if (currentState.isGameOver || currentState.ballCounts[color]! <= 0) {
      return currentState;
    }

    final pos = currentState.path[currentState.currentStep];
    if (!isPlacementValid(
      currentState.gridState,
      pos.row,
      pos.col,
      color,
      currentState.gridSize,
    )) {
      return currentState; // Invalid placement, return current state
    }

    // Create new grid state with the placed ball
    final newGridState = currentState.gridState.map((row) => List<String?>.from(row)).toList();
    newGridState[pos.row][pos.col] = color;

    // Update ball counts
    final newBallCounts = Map<String, int>.from(currentState.ballCounts);
    newBallCounts[color] = newBallCounts[color]! - 1;

    final newCurrentStep = currentState.currentStep + 1;
    final isGameOver = newCurrentStep == currentState.gridSize * currentState.gridSize;

    return currentState.copyWith(
      gridState: newGridState,
      ballCounts: newBallCounts,
      currentStep: newCurrentStep,
      isGameOver: isGameOver,
    );
  }
}
