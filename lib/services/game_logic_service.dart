import 'dart:math';
import '../models/cell_position.dart';
import '../models/game_state.dart';
import '../constants/app_constants.dart';

class SolutionHint {
  final int row;
  final int col;
  final String color;

  SolutionHint(this.row, this.col, this.color);
}

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

  // Generate a valid solution using backtracking
  static List<List<String?>> generateSolution(int gridSize, List<String> colorNames) {
    final solutionBoard = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => null as String?),
    );

    final tempCounts = {for (var color in colorNames) color: gridSize};

    // Try to generate a valid solution
    if (_generateValidSolution(solutionBoard, tempCounts, 0, gridSize, colorNames)) {
      return solutionBoard;
    }

    // If backtracking fails, create a simple but valid pattern
    return _createSimpleValidSolution(gridSize, colorNames);
  }

  static bool _generateValidSolution(
    List<List<String?>> board,
    Map<String, int> counts,
    int step,
    int gridSize,
    List<String> colorNames,
  ) {
    if (step == gridSize * gridSize) {
      return true; // Solution complete
    }

    final row = step ~/ gridSize;
    final col = step % gridSize;

    // Try each color
    for (final color in colorNames) {
      if ((counts[color] ?? 0) > 0 && _isMoveValidForSolution(board, row, col, color, gridSize)) {
        board[row][col] = color;
        counts[color] = (counts[color] ?? 0) - 1;

        if (_generateValidSolution(board, counts, step + 1, gridSize, colorNames)) {
          return true;
        }

        // Backtrack
        board[row][col] = null;
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }

    return false;
  }

  static bool _isMoveValidForSolution(
    List<List<String?>> board,
    int row,
    int col,
    String color,
    int gridSize,
  ) {
    // Check all 8 neighbors (including diagonals)
    for (int rOff = -1; rOff <= 1; rOff++) {
      for (int cOff = -1; cOff <= 1; cOff++) {
        if (rOff == 0 && cOff == 0) continue;
        final checkRow = row + rOff;
        final checkCol = col + cOff;
        if (checkRow >= 0 &&
            checkRow < gridSize &&
            checkCol >= 0 &&
            checkCol < gridSize) {
          if (board[checkRow][checkCol] == color) return false;
        }
      }
    }
    // Check for same color in the same column
    for (int r = 0; r < gridSize; r++) {
      if (board[r][col] == color) return false;
    }
    // Check for same color in the same row
    for (int c = 0; c < gridSize; c++) {
      if (board[row][c] == color) return false;
    }
    return true;
  }

  static List<List<String?>> _createSimpleValidSolution(
    int gridSize,
    List<String> colorNames,
  ) {
    // Create a simple but valid solution as fallback
    final solutionBoard = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => null as String?),
    );

    // Fill row by row, ensuring no conflicts
    for (int row = 0; row < gridSize; row++) {
      final usedInRow = <String>{};
      final usedInCol = <String>{};

      // Get colors already used in this row and column
      for (int c = 0; c < gridSize; c++) {
        if (solutionBoard[row][c] != null) {
          usedInRow.add(solutionBoard[row][c]!);
        }
      }
      for (int r = 0; r < gridSize; r++) {
        if (solutionBoard[r][row] != null) {
          usedInCol.add(solutionBoard[r][row]!);
        }
      }

      // Fill this row with valid colors
      for (int col = 0; col < gridSize; col++) {
        for (final color in colorNames) {
          if (!usedInRow.contains(color) && !usedInCol.contains(color)) {
            // Check adjacent cells
            bool valid = true;
            for (int rOff = -1; rOff <= 1; rOff++) {
              for (int cOff = -1; cOff <= 1; cOff++) {
                if (rOff == 0 && cOff == 0) continue;
                final checkRow = row + rOff;
                final checkCol = col + cOff;
                if (checkRow >= 0 &&
                    checkRow < gridSize &&
                    checkCol >= 0 &&
                    checkCol < gridSize) {
                  if (solutionBoard[checkRow][checkCol] == color) {
                    valid = false;
                    break;
                  }
                }
              }
              if (!valid) break;
            }

            if (valid) {
              solutionBoard[row][col] = color;
              usedInRow.add(color);
              usedInCol.add(color);
              break;
            }
          }
        }
      }
    }

    return solutionBoard;
  }

  // Generate smart clues following the script.js logic
  static List<SolutionHint> generateSmartClues(
    List<List<String?>> solution,
    int gridSize,
    List<String> colorNames,
  ) {
    final clues = <SolutionHint>[];
    final usedRows = <int>{};
    final usedCols = <int>{};
    final usedColors = <String>{};
    final usedPositions = <String>{}; // Track all used positions for diagonal checking

    // Create all possible clue positions
    final allPositions = <CellPosition>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        allPositions.add(CellPosition(row, col));
      }
    }

    // Shuffle positions to get random distribution
    final shuffledPositions = _shuffleArray([...allPositions]);

    // Try to place one clue for each color, ensuring no row/column/diagonal conflicts
    for (final pos in shuffledPositions) {
      final color = solution[pos.row][pos.col]!;

      // Skip if this color, row, or column is already used
      if (usedColors.contains(color) ||
          usedRows.contains(pos.row) ||
          usedCols.contains(pos.col)) {
        continue;
      }

      // Check for diagonal conflicts with existing clues
      if (_hasDiagonalConflict(pos.row, pos.col, usedPositions, gridSize)) {
        continue;
      }

      // Add this clue
      clues.add(SolutionHint(pos.row, pos.col, color));
      usedColors.add(color);
      usedRows.add(pos.row);
      usedCols.add(pos.col);
      usedPositions.add('${pos.row},${pos.col}');

      // Stop when we have one clue per color (up to the number of colors available)
      if (clues.length >= colorNames.length) {
        break;
      }
    }

    return clues;
  }

  static bool _hasDiagonalConflict(
    int row,
    int col,
    Set<String> usedPositions,
    int gridSize,
  ) {
    // Check all 8 diagonal and adjacent positions
    for (int rOff = -1; rOff <= 1; rOff++) {
      for (int cOff = -1; cOff <= 1; cOff++) {
        if (rOff == 0 && cOff == 0) continue; // Skip the cell itself

        final checkRow = row + rOff;
        final checkCol = col + cOff;

        // Check if this position is within bounds and already used
        if (checkRow >= 0 &&
            checkRow < gridSize &&
            checkCol >= 0 &&
            checkCol < gridSize) {
          if (usedPositions.contains('$checkRow,$checkCol')) {
            return true; // Found a diagonal/adjacent conflict
          }
        }
      }
    }
    return false; // No conflicts found
  }

  static List<T> _shuffleArray<T>(List<T> array) {
    final random = Random();
    for (int i = array.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }

  // Update currentStep to skip pre-filled cells in the path
  static int updateCurrentStepForPrefilledCells(
    List<CellPosition> path,
    List<List<String?>> gridState,
  ) {
    // Find the first empty cell in the path
    for (int i = 0; i < path.length; i++) {
      final pos = path[i];
      if (gridState[pos.row][pos.col] == null) {
        return i;
      }
    }
    // If all cells are filled, set to end
    return path.length;
  }

  // Calculate ball counts based on remaining cells
  static Map<String, int> calculateBallCounts(
    List<String> colorNames,
    int gridSize,
    List<List<String?>> gridState,
  ) {
    // Count how many of each color are already placed
    final placedCounts = {for (var color in colorNames) color: 0};

    // Count placed colors
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final color = gridState[row][col];
        if (color != null) {
          placedCounts[color] = (placedCounts[color] ?? 0) + 1;
        }
      }
    }

    // Calculate remaining ball counts
    final ballCounts = <String, int>{};
    for (final color in colorNames) {
      ballCounts[color] = gridSize - (placedCounts[color] ?? 0);
    }

    return ballCounts;
  }

  static GameState initializeGame(int levelIndex) {
    // Use the new method that ensures different colors for pre-filled cells
    return initializeGameWithSolution(levelIndex);
  }

  // Reset level while preserving pre-filled cells
  static GameState resetLevel(GameState currentState) {
    // Store the pre-filled cells before resetting
    final preFilledBackup = Set<String>.from(currentState.preFilledCells);

    // Clear the grid but preserve pre-filled cells
    final newGridState = currentState.gridState.map((row) => List<String?>.from(row)).toList();
    
    for (int row = 0; row < currentState.gridSize; row++) {
      for (int col = 0; col < currentState.gridSize; col++) {
        final cellKey = '$row,$col';
        if (!preFilledBackup.contains(cellKey)) {
          // Only clear cells that are not pre-filled
          newGridState[row][col] = null;
        }
      }
    }

    // Recalculate ball counts based on remaining cells
    final newBallCounts = calculateBallCounts(
      currentState.colorNames,
      currentState.gridSize,
      newGridState,
    );

    // Update current step to first empty cell
    final newCurrentStep = updateCurrentStepForPrefilledCells(currentState.path, newGridState);

    return currentState.copyWith(
      gridState: newGridState,
      ballCounts: newBallCounts,
      currentStep: newCurrentStep,
      isGameOver: false,
      history: [], // Clear history on reset
      preFilledCells: preFilledBackup,
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
    
    // Check if this cell is already filled (pre-filled or already placed)
    if (currentState.gridState[pos.row][pos.col] != null) {
      return currentState;
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

    // Move to next empty position
    final nextStep = updateCurrentStepForPrefilledCells(currentState.path, newGridState);
    final isGameOver = nextStep >= currentState.path.length || 
        !newGridState.any((row) => row.any((cell) => cell == null));

    return currentState.copyWith(
      gridState: newGridState,
      ballCounts: newBallCounts,
      currentStep: nextStep,
      isGameOver: isGameOver,
    );
  }

  // Solve the current puzzle using backtracking
  static List<List<String?>>? solvePuzzle(GameState gameState) {
    // Create a deep copy of the current state
    final board = gameState.gridState.map((row) => List<String?>.from(row)).toList();
    final counts = Map<String, int>.from(gameState.ballCounts);
    final preFilled = Set<String>.from(gameState.preFilledCells);

    // Try to solve using backtracking
    if (_solveHelper(board, counts, gameState.path, gameState.currentStep, gameState.gridSize, gameState.colorNames, preFilled)) {
      return board;
    }
    return null; // No solution found
  }

  static bool _solveHelper(
    List<List<String?>> board,
    Map<String, int> counts,
    List<CellPosition> path,
    int currentStep,
    int gridSize,
    List<String> colorNames,
    Set<String> preFilled,
  ) {
    // If we've reached the end of the path, check if all cells are filled
    if (currentStep >= path.length) {
      return true; // Solution complete
    }

    final pos = path[currentStep];
    
    // Skip if this cell is already filled (pre-filled or already placed)
    if (board[pos.row][pos.col] != null) {
      return _solveHelper(board, counts, path, currentStep + 1, gridSize, colorNames, preFilled);
    }

    // Try each color
    final shuffledColors = List<String>.from(colorNames)..shuffle(Random());
    for (final color in shuffledColors) {
      if ((counts[color] ?? 0) > 0 && isPlacementValid(board, pos.row, pos.col, color, gridSize)) {
        // Place the color
        board[pos.row][pos.col] = color;
        counts[color] = counts[color]! - 1;

        // Recursively try to solve the rest
        if (_solveHelper(board, counts, path, currentStep + 1, gridSize, colorNames, preFilled)) {
          return true;
        }

        // Backtrack: remove the color
        board[pos.row][pos.col] = null;
        counts[color] = counts[color]! + 1;
      }
    }

    return false; // No valid color found for this cell
  }

  // Generate solution with different colors for pre-filled cells
  static GameState initializeGameWithSolution(int levelIndex, [List<List<String?>>? providedSolution]) {
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) {
      throw ArgumentError('Invalid level index: $levelIndex');
    }

    final config = AppConstants.levelConfig[levelIndex];
    final gridSize = config['gridSize'] as int;
    final colorNames = List<String>.from(config['colors'] as List);
    
    // Generate or use provided solution
    List<List<String?>> solution;
    if (providedSolution != null) {
      solution = providedSolution;
    } else {
      solution = generateSolution(gridSize, colorNames);
    }
    
    // Create empty grid
    final gridState = List.generate(
      gridSize, 
      (_) => List.generate(gridSize, (_) => null as String?)
    );
    
    // Generate smart clues with each clue having a different color
    final clues = _generateCluesWithDifferentColors(solution, gridSize, colorNames);
    final preFilledCells = <String>{};
    
    print('DEBUG: Generated ${clues.length} clues for grid size $gridSize');
    
    // Apply the clues to the grid and track them as pre-filled
    for (final clue in clues) {
      gridState[clue.row][clue.col] = clue.color;
      preFilledCells.add('${clue.row},${clue.col}');
      print('DEBUG: Placed clue at row=${clue.row}, col=${clue.col}, color=${clue.color}');
    }
    
    print('DEBUG: Total pre-filled cells: ${preFilledCells.length}');
    
    // Calculate ball counts based on remaining cells
    final ballCounts = calculateBallCounts(colorNames, gridSize, gridState);
    
    final path = generateSnakePath(gridSize);
    
    // Update currentStep to skip pre-filled cells in the path
    final currentStep = updateCurrentStepForPrefilledCells(path, gridState);

    return GameState(
      currentLevel: levelIndex,
      gridSize: gridSize,
      colorNames: colorNames,
      ballCounts: ballCounts,
      gridState: gridState,
      path: path,
      currentStep: currentStep,
      isGameOver: false,
      preFilledCells: preFilledCells,
    );
  }

  // Generate clues ensuring one pre-filled cell per column with unique colors
  static List<SolutionHint> _generateCluesWithDifferentColors(
    List<List<String?>> solution,
    int gridSize,
    List<String> colorNames,
  ) {
    final clues = <SolutionHint>[];
    final usedCols = <int>{};
    final usedRows = <int>{};
    final usedColors = <String>{};
    final usedPositions = <String>{};

    // Create positions for each column
    final positionsByColumn = <int, List<CellPosition>>{};
    for (int col = 0; col < gridSize; col++) {
      positionsByColumn[col] = [];
      for (int row = 0; row < gridSize; row++) {
        positionsByColumn[col]!.add(CellPosition(row, col));
      }
      // Shuffle positions within each column for randomness
      positionsByColumn[col] = _shuffleArray(positionsByColumn[col]!);
    }

    // Try to place one clue per column with unique colors
    for (int col = 0; col < gridSize; col++) {
      final positions = positionsByColumn[col]!;
      bool placedClue = false;
      print('DEBUG: Processing column $col');
      
      for (final pos in positions) {
        final color = solution[pos.row][pos.col]!;

        // Skip if this column is already used
        if (usedCols.contains(pos.col)) {
          print('DEBUG: Column $col already used, breaking');
          break;
        }

        // Skip if this row or color is already used
        if (usedRows.contains(pos.row) || usedColors.contains(color)) {
          print('DEBUG: Position row=${pos.row} col=${pos.col} color=$color rejected (row or color used)');
          continue;
        }

        // Check for diagonal conflicts with existing clues
        if (_hasDiagonalConflict(pos.row, pos.col, usedPositions, gridSize)) {
          print('DEBUG: Position row=${pos.row} col=${pos.col} rejected (diagonal conflict)');
          continue;
        }

        // Add this clue
        clues.add(SolutionHint(pos.row, pos.col, color));
        usedRows.add(pos.row);
        usedCols.add(pos.col);
        usedColors.add(color);
        usedPositions.add('${pos.row},${pos.col}');
        placedClue = true;
        print('DEBUG: Placed clue at column $col: row=${pos.row}, color=$color');
        break; // Move to next column
      }

      // If we couldn't place a clue in this column, try to place one with a unique color
      if (!placedClue && usedCols.length < gridSize) {
        print('DEBUG: Failed to place clue in column $col, trying fallback');
        // Find any position in this column that hasn't been used with a unique color
        for (int row = 0; row < gridSize; row++) {
          if (!usedRows.contains(row)) {
            final color = solution[row][col]!;
            // Only add if color is unique
            if (!usedColors.contains(color)) {
              clues.add(SolutionHint(row, col, color));
              usedRows.add(row);
              usedCols.add(col);
              usedColors.add(color);
              usedPositions.add('$row,$col');
              print('DEBUG: Fallback placed clue at column $col: row=$row, color=$color');
              break;
            }
          }
        }
      }
      
      print('DEBUG: After column $col: total clues=${clues.length}, usedCols=$usedCols');
    }
    
    print('DEBUG: Final total clues: ${clues.length}');

    return clues;
  }
}
