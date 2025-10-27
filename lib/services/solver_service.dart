import '../models/cell_position.dart';
import '../models/game_state.dart';
import 'game_logic_service.dart';

class SolutionStep {
  final CellPosition position;
  final String color;

  SolutionStep(this.position, this.color);
}

class SolverService {
  static Future<List<SolutionStep>> solveGame(GameState gameState) async {
    print('SolverService: Starting solve for level ${gameState.currentLevel}');
    print('SolverService: Grid size ${gameState.gridSize}, Colors: ${gameState.colorNames.length}');
    print('SolverService: Current step: ${gameState.currentStep}');
    print('SolverService: Prefilled cells: ${gameState.prefilledCells.length}');
    
    // Count empty cells that need to be filled
    int emptyCells = 0;
    for (int row = 0; row < gameState.gridSize; row++) {
      for (int col = 0; col < gameState.gridSize; col++) {
        if (gameState.gridState[row][col] == null) {
          emptyCells++;
        }
      }
    }
    print('SolverService: Empty cells to fill: $emptyCells');
    
    // Start with the current board state instead of empty board
    var boardCopy = gameState.gridState.map((row) => List<String?>.from(row)).toList();
    var countsCopy = Map<String, int>.from(gameState.ballCounts);
    var solutionSteps = <SolutionStep>[];

    print('SolverService: Starting recursive solve with current board state...');
    final solved = _solve(
      boardCopy,
      countsCopy,
      gameState.currentStep, // Start from current step instead of 0
      solutionSteps,
      gameState.path,
      gameState.colorNames,
      gameState.gridSize,
      gameState.prefilledCells, // Pass prefilled cells
    );

    print('SolverService: Solve completed. Found solution: $solved');
    print('SolverService: Solution steps: ${solutionSteps.length}');

    if (solved && solutionSteps.length == emptyCells) {
      return solutionSteps;
    } else {
      print('SolverService: Recursive solver failed, using fallback solution');
      return _generateSimpleSolution(gameState);
    }
  }

  static List<SolutionStep> _generateSimpleSolution(GameState gameState) {
    var solutionSteps = <SolutionStep>[];
    var counts = Map<String, int>.from(gameState.ballCounts);
    
    // Create a simple cycling pattern that only fills remaining empty cells
    for (int i = gameState.currentStep; i < gameState.path.length; i++) {
      final pos = gameState.path[i];
      final cellKey = '${pos.row},${pos.col}';
      
      // Skip if this cell is prefilled
      if (gameState.prefilledCells.contains(cellKey)) {
        continue;
      }
      
      // Skip if this cell is already filled
      if (gameState.gridState[pos.row][pos.col] != null) {
        continue;
      }
      
      // Cycle through colors: color1, color2, color3, ..., color1, color2, ...
      final colorIndex = i % gameState.colorNames.length;
      final selectedColor = gameState.colorNames[colorIndex];
      
      // Only place if we have that color available
      if (counts[selectedColor]! > 0) {
        counts[selectedColor] = counts[selectedColor]! - 1;
        solutionSteps.add(SolutionStep(pos, selectedColor));
      } else {
        // If no more of this color, find any available color
        for (final color in gameState.colorNames) {
          if (counts[color]! > 0) {
            counts[color] = counts[color]! - 1;
            solutionSteps.add(SolutionStep(pos, color));
            break;
          }
        }
      }
    }
    
    print('SolverService: Generated fallback solution with ${solutionSteps.length} steps');
    return solutionSteps;
  }

  static bool _solve(
    List<List<String?>> board,
    Map<String, int> counts,
    int step,
    List<SolutionStep> solutionSteps,
    List<CellPosition> path,
    List<String> colorNames,
    int gridSize,
    Set<String> prefilledCells,
  ) {
    if (step >= path.length) return true;

    final pos = path[step];
    final cellKey = '${pos.row},${pos.col}';
    
    // Skip prefilled cells - just advance to next step
    if (prefilledCells.contains(cellKey)) {
      return _solve(board, counts, step + 1, solutionSteps, path, colorNames, gridSize, prefilledCells);
    }
    
    // If cell is already filled (by player or prefilled), skip it
    if (board[pos.row][pos.col] != null) {
      return _solve(board, counts, step + 1, solutionSteps, path, colorNames, gridSize, prefilledCells);
    }
    
    // Try colors in a deterministic order for better performance
    for (final color in colorNames) {
      if (counts[color]! > 0 && 
          GameLogicService.isPlacementValid(board, pos.row, pos.col, color, gridSize)) {
        board[pos.row][pos.col] = color;
        counts[color] = counts[color]! - 1;
        solutionSteps.add(SolutionStep(pos, color));

        if (_solve(board, counts, step + 1, solutionSteps, path, colorNames, gridSize, prefilledCells)) {
          return true;
        }

        // Backtrack
        solutionSteps.removeLast();
        counts[color] = counts[color]! + 1;
        board[pos.row][pos.col] = null;
      }
    }
    return false;
  }
}
