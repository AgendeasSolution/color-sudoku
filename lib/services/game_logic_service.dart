import 'dart:math';
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

  /// Generate prefilled cells: one per color with unique rows, columns, and no adjacency
  /// Guarantees all colors are placed by retrying with fewer constraints if needed
  static Set<String> generatePrefilledCells(
    List<String> colorNames,
    int gridSize,
    Map<String, int> ballCounts,
    List<List<String?>> gridState,
  ) {
    // Try multiple times with different randomizations
    for (int attempt = 0; attempt < 50; attempt++) {
      final prefilledCells = <String>{};
      final usedRows = <int>{};
      final usedCols = <int>{};
      
      // Reset ball counts for this attempt
      for (var name in colorNames) {
        ballCounts[name] = gridSize;
      }
      
      // Shuffle colors for randomness
      final shuffledColors = List<String>.from(colorNames)..shuffle(Random());
      
      // Try to place each color
      bool allPlaced = true;
      for (final color in shuffledColors) {
        bool placed = false;
        
        // Create all positions and shuffle them
        final allPositions = <CellPosition>[];
        for (int row = 0; row < gridSize; row++) {
          for (int col = 0; col < gridSize; col++) {
            allPositions.add(CellPosition(row, col));
          }
        }
        allPositions.shuffle(Random());
        
        for (final pos in allPositions) {
          // Check if row or column already used
          if (usedRows.contains(pos.row) || usedCols.contains(pos.col)) continue;
          
          // Check if adjacent to any existing prefilled cell
          bool isAdjacent = false;
          for (final cellKey in prefilledCells) {
            final parts = cellKey.split(',');
            final existingRow = int.parse(parts[0]);
            final existingCol = int.parse(parts[1]);
            if ((pos.row - existingRow).abs() <= 1 && (pos.col - existingCol).abs() <= 1) {
              isAdjacent = true;
              break;
            }
          }
          if (isAdjacent) continue;
          
          // Place the color
          final cellKey = '${pos.row},${pos.col}';
          prefilledCells.add(cellKey);
          usedRows.add(pos.row);
          usedCols.add(pos.col);
          gridState[pos.row][pos.col] = color;
          ballCounts[color] = ballCounts[color]! - 1;
          placed = true;
          break;
        }
        
        if (!placed) {
          allPlaced = false;
          break;
        }
      }
      
      // If we successfully placed all colors, return
      if (allPlaced && prefilledCells.length == colorNames.length) {
        return prefilledCells;
      }
      
      // Otherwise, clear the grid for next attempt
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          gridState[row][col] = null;
        }
      }
    }
    
    // If we still can't place all, just place what we can (shouldn't happen)
    print('Warning: Could not place all prefilled cells after 50 attempts');
    return {};
  }

  static GameState initializeGame(int levelIndex) {
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) {
      throw ArgumentError('Invalid level index: $levelIndex');
    }

    final config = AppConstants.levelConfig[levelIndex];
    final gridSize = config['gridSize'] as int;
    final colorNames = List<String>.from(config['colors'] as List);
    final ballCounts = {for (var name in colorNames) name: gridSize};
    final gridState = List.generate(
      gridSize, 
      (_) => List.generate(gridSize, (_) => null as String?)
    );
    final path = generateSnakePath(gridSize);
    
    // Generate prefilled cells
    final prefilledCells = generatePrefilledCells(colorNames, gridSize, ballCounts, gridState);
    
    // Find the first position in path that is not prefilled
    int initialStep = 0;
    for (int i = 0; i < path.length; i++) {
      final pos = path[i];
      final cellKey = '${pos.row},${pos.col}';
      if (!prefilledCells.contains(cellKey)) {
        initialStep = i;
        break;
      }
    }

    return GameState(
      currentLevel: levelIndex,
      gridSize: gridSize,
      colorNames: colorNames,
      ballCounts: ballCounts,
      gridState: gridState,
      path: path,
      currentStep: initialStep,
      isGameOver: false,
      prefilledCells: prefilledCells,
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
    
    // Check if trying to place on a prefilled cell
    final cellKey = '${pos.row},${pos.col}';
    if (currentState.prefilledCells.contains(cellKey)) {
      return currentState; // Cannot modify prefilled cells
    }
    
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

    // Move to next position, skipping over prefilled cells
    int nextStep = currentState.currentStep + 1;
    while (nextStep < currentState.path.length) {
      final nextPos = currentState.path[nextStep];
      final nextCellKey = '${nextPos.row},${nextPos.col}';
      if (!currentState.prefilledCells.contains(nextCellKey)) {
        break;
      }
      nextStep++;
    }
    
    final isGameOver = nextStep >= currentState.path.length;

    return currentState.copyWith(
      gridState: newGridState,
      ballCounts: newBallCounts,
      currentStep: nextStep,
      isGameOver: isGameOver,
    );
  }
}
