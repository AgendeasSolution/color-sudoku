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
    return GameLogicService.isPlacementValid(
      gameState.gridState,
      pos.row,
      pos.col,
      color,
      gameState.gridSize,
    );
  }

  static bool isGameComplete(GameState gameState) {
    return gameState.currentStep == gameState.gridSize * gameState.gridSize;
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
