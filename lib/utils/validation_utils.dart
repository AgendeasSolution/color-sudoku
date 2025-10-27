import '../models/game_state.dart';
import '../services/game_logic_service.dart';

class ValidationUtils {
  static bool canPlaceColor(
    GameState gameState,
    String color,
  ) {
    if (gameState.isGameOver || gameState.ballCounts[color]! <= 0) {
      return false;
    }

    final pos = gameState.path[gameState.currentStep];
    
    // Check if trying to place on a prefilled cell
    final cellKey = '${pos.row},${pos.col}';
    if (gameState.prefilledCells.contains(cellKey)) {
      return false; // Cannot place on prefilled cells
    }
    
    return GameLogicService.isPlacementValid(
      gameState.gridState,
      pos.row,
      pos.col,
      color,
      gameState.gridSize,
    );
  }

  static bool isGameComplete(GameState gameState) {
    // Game is complete when all non-prefilled cells in the path are filled
    // This happens when currentStep reaches the end of the path
    return gameState.currentStep >= gameState.path.length;
  }

  static bool isGameOver(GameState gameState) {
    return GameLogicService.checkIfAllBallsBlocked(
      gameState.colorNames,
      gameState.ballCounts,
      gameState.gridState,
      gameState.path,
      gameState.currentStep,
      gameState.gridSize,
    );
  }

  static bool hasValidMoves(GameState gameState) {
    if (gameState.isGameOver) return false;
    
    final invalidColors = GameLogicService.getInvalidColorsForNextStep(
      gameState.gridState,
      gameState.path,
      gameState.currentStep,
      gameState.gridSize,
    );
    
    return gameState.colorNames.any((color) =>
        gameState.ballCounts[color]! > 0 && !invalidColors.contains(color)
    );
  }
}
