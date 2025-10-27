import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/cell_position.dart';
import '../models/game_state.dart';
import '../models/modal_types.dart';
import '../services/game_logic_service.dart';
import '../services/level_progression_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/rewarded_ad_service.dart';
import '../services/audio_service.dart';
import '../utils/color_utils.dart';
import '../utils/validation_utils.dart';
import '../utils/responsive_utils.dart';
import '../widgets/components/ad_banner.dart';
import '../widgets/components/color_ball.dart';
import '../widgets/components/gradient_border_container.dart';
import '../widgets/components/grid_cell.dart';
import '../widgets/modals/modal_button.dart';
import '../widgets/modals/modal_container.dart';

class GameScreen extends StatefulWidget {
  final int initialLevel;
  final VoidCallback onGoHome;

  const GameScreen({
    super.key,
    required this.initialLevel,
    required this.onGoHome,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game State
  GameState _gameState = GameState(
    currentLevel: 0,
    gridSize: 0,
    colorNames: [],
    ballCounts: {},
    gridState: [],
    path: [],
    currentStep: 0,
    isGameOver: false,
  );
  
  Map<String, Color> _colors = {};
  List<CellPosition> _conflictingCells = [];

  // UI State
  ModalType _activeModal = ModalType.none;

  // Animation Controllers
  late final AnimationController _bgAnimationController;
  late final AnimationController _modalAnimationController;
  late final AnimationController _shakeAnimationController;
  late final AnimationController _ballTapAnimationController;

  // Key to access GridView state for animations
  final GlobalKey _gridKey = GlobalKey();
  
  // Track which color ball is being animated
  String? _animatingColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    _startLevel(widget.initialLevel);
    // Preload ads for better user experience
    InterstitialAdService.instance.preloadAd();
    // Initialize rewarded ad service for solution button
    RewardedAdService.instance.preloadAd();
    // Show interstitial ad on entry with 50% probability
    _showEntryAd();
  }

  void _initializeAnimationControllers() {
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.backgroundAnimationDuration,
    )..repeat();

    _modalAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.modalAnimationDuration,
      reverseDuration: AppConstants.modalReverseDuration,
    );

    _shakeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460), // 1.3x faster
    );
    
    _ballTapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _modalAnimationController.dispose();
    _shakeAnimationController.dispose();
    _ballTapAnimationController.dispose();
    super.dispose();
  }

  // --- Game Logic ---

  /// Show interstitial ad on entry with 50% probability
  void _showEntryAd() {
    // Add a small delay to ensure the game screen is fully rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // Show interstitial ad with 50% probability
      InterstitialAdService.instance.showAdWithProbability(
        onAdDismissed: () {
          // Ad dismissed, continue playing
          // Preload next ad for future use
          InterstitialAdService.instance.preloadAd();
        },
      );
    });
  }

  void _startLevel(int levelIndex) {
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) return;

    setState(() {
      _gameState = GameLogicService.initializeGame(levelIndex);
      _gameState = _gameState.copyWith(history: []); // Clear history for new level
      _colors = ColorUtils.getColorsForLevel(_gameState.colorNames);
    });
  }

  /// Restart level with interstitial ad (50% probability)
  Future<void> _restartLevelWithAd(int levelIndex) async {
    // Try to show interstitial ad with 50% probability
    final adShown = await InterstitialAdService.instance.showAdWithProbability(
      onAdDismissed: () {
        // This callback is called when ad is dismissed
        if (levelIndex == _gameState.currentLevel) {
          // Same level - reset preserving pre-filled cells
          setState(() {
            _gameState = GameLogicService.resetLevel(_gameState);
          });
        } else {
          // Different level - start new level
          _startLevel(levelIndex);
        }
        // Preload next ad for future use
        InterstitialAdService.instance.preloadAd();
      },
    );

    // If ad was not shown (50% chance), restart immediately
    if (!adShown) {
      if (levelIndex == _gameState.currentLevel) {
        // Same level - reset preserving pre-filled cells
        setState(() {
          _gameState = GameLogicService.resetLevel(_gameState);
        });
      } else {
        // Different level - start new level
        _startLevel(levelIndex);
      }
      // Preload next ad for future use
      InterstitialAdService.instance.preloadAd();
    }
  }

  /// Next level with interstitial ad (100% probability - always show)
  Future<void> _nextLevelWithAd() async {
    // Show interstitial ad with 100% probability (always show)
    final adShown = await InterstitialAdService.instance.showAdAlways(
      onAdDismissed: () {
        // This callback is called when ad is dismissed
        _startLevel(_gameState.currentLevel + 1);
        // Preload next ad for future use
        InterstitialAdService.instance.preloadAd();
      },
    );

    // If ad failed to load, proceed to next level anyway
    if (!adShown) {
      _startLevel(_gameState.currentLevel + 1);
      // Preload next ad for future use
      InterstitialAdService.instance.preloadAd();
    }
  }

  void _handleColorSelection(String color) {
    if (!ValidationUtils.canPlaceColor(_gameState, color)) {
      // Play invalid move sound
      AudioService().playInvalidMove();
      
      // Trigger animation for the selected color ball only if invalid
      setState(() {
        _animatingColor = color;
      });
      _ballTapAnimationController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _animatingColor = null;
          });
        }
      });
      
      final pos = _gameState.path[_gameState.currentStep];
      _showInvalidMoveWarning(pos, color);
      return;
    }

    // Play valid move sound
    AudioService().playValidMove();

    setState(() {
      // Save current state to history before making a move
      final history = List<GameStateSnapshot>.from(_gameState.history);
      history.add(GameStateSnapshot(
        gridState: _gameState.gridState.map((row) => List<String?>.from(row)).toList(),
        ballCounts: Map<String, int>.from(_gameState.ballCounts),
        currentStep: _gameState.currentStep,
      ));
      
      // Update history and place ball
      _gameState = _gameState.copyWith(history: history);
      _gameState = GameLogicService.placeBall(_gameState, color);
      
      if (ValidationUtils.isGameComplete(_gameState)) {
        _winGame();
      } else if (ValidationUtils.isGameOver(_gameState)) {
        _gameOver();
      }
    });
  }

  Future<void> _showSolution() async {
    AudioService().playButtonClick();
    
    bool rewardEarned = false;
    
    // Show rewarded ad to get solution
    final adShown = await RewardedAdService.instance.showAdAlways(
      onAdDismissed: () {
        // This callback is called when ad is dismissed
        // Only show solution if reward was earned
        if (rewardEarned) {
          _showSolutionAfterAd();
        }
        // Preload next ad for future use
        RewardedAdService.instance.preloadAd();
      },
      onRewardEarned: () {
        // This callback is called when user watches the ad and earns reward
        rewardEarned = true;
      },
    );

    // If ad failed to load, show solution anyway
    if (!adShown) {
      _showSolutionAfterAd();
      // Preload next ad for future use
      RewardedAdService.instance.preloadAd();
    }
  }

  void _showSolutionAfterAd() {
    // Try to solve the puzzle
    final solution = GameLogicService.solvePuzzle(_gameState);

    if (solution != null) {
      // Animate the solution step by step following the snake path
      _animateSolution(solution);
    } else {
      // If no solution found, show error modal
      _showModal(ModalType.noSolution);
    }
  }

  void _animateSolution(List<List<String?>> completeSolution) {
    // Get the current path
    final path = _gameState.path;
    
    // Start animation
    int currentIndex = 0;
    
    // Timer to animate each cell
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentIndex >= path.length) {
        timer.cancel();
        // Mark game as over after animation completes
        setState(() {
          _gameState = _gameState.copyWith(isGameOver: true);
        });
        return;
      }
      
      final pos = path[currentIndex];
      
      // Only animate cells that are currently empty (not pre-filled)
      if (_gameState.gridState[pos.row][pos.col] == null) {
        final color = completeSolution[pos.row][pos.col];
        
        setState(() {
          final newGridState = _gameState.gridState.map((row) => List<String?>.from(row)).toList();
          newGridState[pos.row][pos.col] = color;
          
          _gameState = _gameState.copyWith(gridState: newGridState);
        });
      }
      
      currentIndex++;
    });
  }

  void _playAgain() {
    AudioService().playButtonClick();
    
    // Reset the level preserving pre-filled cells
    setState(() {
      _gameState = GameLogicService.resetLevel(_gameState);
    });
  }

  void _undoMove() {
    if (_gameState.history.isEmpty) return;
    
    AudioService().playButtonClick();
    
    setState(() {
      final history = List<GameStateSnapshot>.from(_gameState.history);
      final previousState = history.removeLast();
      
      _gameState = _gameState.copyWith(
        gridState: previousState.gridState.map((row) => List<String?>.from(row)).toList(),
        ballCounts: Map<String, int>.from(previousState.ballCounts),
        currentStep: previousState.currentStep,
        history: history,
        isGameOver: false, // Reset game over state on undo
      );
    });
  }

  void _winGame() async {
    // Play win sound
    AudioService().playWin();
    
    setState(() {
      _gameState = _gameState.copyWith(isGameOver: true);
    });
    
    // Mark the current level as completed
    await LevelProgressionService.completeLevel(_gameState.currentLevel);
    
    if (_gameState.currentLevel < AppConstants.levelConfig.length - 1) {
      _showModal(ModalType.levelComplete);
    } else {
      _showModal(ModalType.gameComplete);
    }
  }

  void _gameOver() {
    // Play fail sound
    AudioService().playFail();
    
    setState(() {
      _gameState = _gameState.copyWith(isGameOver: true);
    });
    _showModal(ModalType.gameOver);
  }

  // --- UI and Animation Methods ---

  void _showInvalidMoveWarning(CellPosition pos, String color) {
    setState(() {
      // Don't shake the target cell - only show conflicting cells
      // Get all cells that conflict with this color placement
      _conflictingCells = GameLogicService.getConflictingCells(
        _gameState.gridState,
        pos.row,
        pos.col,
        color,
        _gameState.gridSize,
      );
    });
    _shakeAnimationController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _conflictingCells = [];
        });
      }
    });
  }

  void _showModal(ModalType type) {
    setState(() => _activeModal = type);
    _modalAnimationController.forward(from: 0.0);
  }

  void _hideModal() {
    _modalAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() => _activeModal = ModalType.none);
      }
    });
  }

  void _onModalAction(ModalAction action) {
    // Play button click sound for modal actions
    AudioService().playButtonClick();
    
    _hideModal();
    Future.delayed(AppConstants.modalActionDelay, () {
      if (!mounted) return;
      
      switch (action) {
        case ModalAction.nextLevel:
          _nextLevelWithAd();
          break;
        case ModalAction.restartLevel:
          _restartLevelWithAd(_gameState.currentLevel);
          break;
        case ModalAction.restartGame:
          _restartLevelWithAd(0);
          break;
        case ModalAction.playAgain:
          _restartLevelWithAd(_gameState.currentLevel);
          break;
        case ModalAction.close:
          // just close
          break;
      }
    });
  }

  /// Exit to home with interstitial ad (100% probability - always show)
  Future<void> _goHomeWithAd() async {
    // Show interstitial ad with 100% probability (always show)
    final adShown = await InterstitialAdService.instance.showAdAlways(
      onAdDismissed: () {
        // This callback is called when ad is dismissed - exit immediately
        widget.onGoHome();
        // Preload next ad for future use (non-blocking)
        Future.delayed(Duration.zero, () {
          InterstitialAdService.instance.preloadAd();
        });
      },
    );

    // If ad failed to load, exit immediately
    if (!adShown) {
      widget.onGoHome();
      // Preload next ad for future use (non-blocking)
      Future.delayed(Duration.zero, () {
        InterstitialAdService.instance.preloadAd();
      });
    }
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: AnimatedBuilder(
        animation: _bgAnimationController,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.backgroundColor,
                  AppConstants.secondaryBackgroundColor,
                  AppConstants.tertiaryBackgroundColor,
                  AppConstants.backgroundColor,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          _buildAnimatedBackground(),
                          SafeArea(
                            child: _buildGameUI(),
                          ),
                        ],
                      ),
                    ),
                    const AdBanner(),
                  ],
                ),
                if (_activeModal != ModalType.none) _buildModalOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        final val = _bgAnimationController.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.backgroundColor,
                AppConstants.secondaryBackgroundColor,
                AppConstants.tertiaryBackgroundColor,
                AppConstants.backgroundColor,
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildGradientCircle(
                Alignment(sin(val * 2 * pi) * 0.6, cos(val * 2 * pi) * 0.6),
                const Color(0xFF63B3ED).withOpacity(AppConstants.backgroundCircleOpacity),
              ),
              _buildGradientCircle(
                Alignment(cos(val * 2 * pi) * 0.7, sin(val * 2 * pi + pi / 2) * 0.7),
                const Color(0xFF9F7AEA).withOpacity(AppConstants.backgroundCircleSecondaryOpacity),
              ),
              _buildGradientCircle(
                Alignment(sin(val * 2 * pi + pi) * 0.5, cos(val * 2 * pi) * 0.5),
                const Color(0xFF38B2AC).withOpacity(AppConstants.backgroundCircleTertiaryOpacity),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientCircle(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: AppConstants.backgroundCircleSize,
        height: AppConstants.backgroundCircleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildGameUI() {
    return Stack(
      children: [
        // Top navigation bar - positioned at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopNavBar(),
        ),
        // Action buttons row - positioned below nav bar
        _buildActionButtonsRow(),
        // Centered game elements - truly centered on screen
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getGameCenterOffset(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGameGrid(),
                SizedBox(height: ResponsiveUtils.getGameElementSpacing(context)),
                _buildColorPalette(),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTopNavBar() {
    return Padding(
      padding: ResponsiveUtils.getTopNavBarPadding(context),
      child: Row(
        children: [
          // Exit button (left) - back arrow icon only
          GestureDetector(
            onTap: () {
              AudioService().playButtonClick();
              _goHomeWithAd();
            },
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing)
              ),
              decoration: BoxDecoration(
                color: AppConstants.borderColor,
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppConstants.textPrimaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
          ),
          // Level text (center) - balanced layout
          Expanded(
            child: Center(
              child: Text(
                'Level ${_gameState.currentLevel + 1}',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFontFamily,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: AppConstants.boldWeight,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),
          ),
          // Invisible spacer to balance the left button
          SizedBox(
            width: ResponsiveUtils.getResponsiveIconSize(context) + 
                   (ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing) * 2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    // Check if solution has been shown (game is over due to solution, not win/loss)
    final bool solutionShown = _gameState.isGameOver && 
                                _gameState.gridState.every((row) => row.every((cell) => cell != null)) &&
                                !ValidationUtils.isGameComplete(_gameState);

    return Positioned(
      top: ResponsiveUtils.getSolutionButtonTopPosition(context),
      left: 0,
      right: 0,
      child: Padding(
        padding: ResponsiveUtils.getTopNavBarPadding(context),
        child: solutionShown
            ? _buildPlayAgainButton()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Solution button
                  Expanded(
                    child: GestureDetector(
                      onTap: !_gameState.isGameOver ? _showSolution : null,
                      child: Container(
                        padding: ResponsiveUtils.getSolutionButtonPadding(context),
                        decoration: BoxDecoration(
                          color: _gameState.isGameOver
                              ? AppConstants.borderColor.withOpacity(0.5)
                              : const Color(0xFFD69E2E), // Gold color for solution button
                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: AppConstants.textPrimaryColor,
                              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
                            ),
                            SizedBox(
                              width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                            ),
                            Flexible(
                              child: Text(
                                'Watch Ad for Solution',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFontFamily,
                                  fontSize: ResponsiveUtils.getSolutionButtonFontSize(context),
                                  fontWeight: AppConstants.boldWeight,
                                  color: AppConstants.textPrimaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  
                  // Undo button
                  Expanded(
                    child: GestureDetector(
                      onTap: _gameState.history.isEmpty ? null : _undoMove,
                      child: Container(
                        padding: ResponsiveUtils.getSolutionButtonPadding(context),
                        decoration: BoxDecoration(
                          color: _gameState.history.isEmpty 
                              ? AppConstants.borderColor.withOpacity(0.5)
                              : AppConstants.successColor,
                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.undo,
                              color: AppConstants.textPrimaryColor,
                              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
                            ),
                            SizedBox(
                              width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                            ),
                            Flexible(
                              child: Text(
                                'Undo',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFontFamily,
                                  fontSize: ResponsiveUtils.getSolutionButtonFontSize(context),
                                  fontWeight: AppConstants.boldWeight,
                                  color: AppConstants.textPrimaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  
                  // Reset button
                  Expanded(
                    child: GestureDetector(
                      onTap: _gameState.history.isEmpty ? null : () {
                        AudioService().playButtonClick();
                        _restartLevelWithAd(_gameState.currentLevel);
                      },
                      child: Container(
                        padding: ResponsiveUtils.getSolutionButtonPadding(context),
                        decoration: BoxDecoration(
                          color: _gameState.history.isEmpty 
                              ? AppConstants.borderColor.withOpacity(0.5)
                              : AppConstants.errorColor,
                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppConstants.textPrimaryColor,
                              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
                            ),
                            SizedBox(
                              width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                            ),
                            Flexible(
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFontFamily,
                                  fontSize: ResponsiveUtils.getSolutionButtonFontSize(context),
                                  fontWeight: AppConstants.boldWeight,
                                  color: AppConstants.textPrimaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayAgainButton() {
    return Center(
      child: GestureDetector(
        onTap: _playAgain,
        child: Container(
          padding: ResponsiveUtils.getSolutionButtonPadding(context),
          decoration: BoxDecoration(
            color: const Color(0xFFD69E2E), // Gold color
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                color: AppConstants.textPrimaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Text(
                'Play Again',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFontFamily,
                  fontSize: ResponsiveUtils.getSolutionButtonFontSize(context) * 1.2,
                  fontWeight: AppConstants.boldWeight,
                  color: AppConstants.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    CellPosition? nextPos = _gameState.isGameOver || _gameState.currentStep >= _gameState.path.length 
        ? null 
        : _gameState.path[_gameState.currentStep];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isTablet(context) ? 600 : double.infinity,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GradientBorderContainer(
                key: _gridKey,
                padding: EdgeInsets.all(ResponsiveUtils.getGridPadding(context) + 4),
                borderRadius: AppConstants.gridBorderRadius,
                borderWidth: AppConstants.cellBorderWidth,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gameState.gridSize,
                    mainAxisSpacing: ResponsiveUtils.getCellSpacing(context),
                    crossAxisSpacing: ResponsiveUtils.getCellSpacing(context),
                  ),
                  itemCount: _gameState.gridSize * _gameState.gridSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ _gameState.gridSize;
                    final col = index % _gameState.gridSize;
                    final isNextCell = nextPos != null && nextPos.row == row && nextPos.col == col;
                    final colorName = _gameState.gridState[row][col];
                    final isPrefilled = _gameState.preFilledCells.contains('$row,$col');
                    
                    // Check if this cell is a conflicting cell
                    final isConflictingCell = _conflictingCells.any(
                      (cell) => cell.row == row && cell.col == col,
                    );

                    Widget cell = GridCell(
                      color: colorName != null ? _colors[colorName] : null,
                      isNext: isNextCell,
                      isPrefilled: isPrefilled,
                    );
                    
                    // Animate conflicting cells (balls that prevent placement)
                    if (isConflictingCell && colorName != null) {
                      return AnimatedBuilder(
                        animation: _shakeAnimationController,
                        builder: (context, child) {
                          // Faster shake (1.3x frequency)
                          double offset = sin(_shakeAnimationController.value * 2 * pi * 1.3) * AppConstants.shakeAmplitude;
                          // Smoother pulse for the red glow
                          double glowOpacity = 0.4 + 0.3 * sin(_shakeAnimationController.value * 2 * pi);
                          
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(glowOpacity),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: cell,
                      );
                    }
                    
                    return cell;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPalette() {
    final invalidColors = GameLogicService.getInvalidColorsForNextStep(
      _gameState.gridState,
      _gameState.path,
      _gameState.currentStep,
      _gameState.gridSize,
    );
    
    return Padding(
      padding: ResponsiveUtils.getTopNavBarPadding(context),
      child: Container(
        padding: ResponsiveUtils.getColorPalettePadding(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.colorPaletteBorderRadius),
          border: Border.all(
            color: AppConstants.borderColor,
            width: AppConstants.cellBorderWidth,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppConstants.cardBackgroundColor, AppConstants.cardSecondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildColorPaletteGrid(invalidColors),
      ),
    );
  }

  Widget _buildColorPaletteGrid(Set<String> invalidColors) {
    final colorsPerRow = ResponsiveUtils.isTablet(context) ? 7 : 5;
    final colorNames = _gameState.colorNames;
    final int totalRows = (colorNames.length / colorsPerRow).ceil();
    
    final ballSize = ResponsiveUtils.getBallSize(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalRows, (rowIndex) {
        final startIndex = rowIndex * colorsPerRow;
        final endIndex = (startIndex + colorsPerRow).clamp(0, colorNames.length);
        final rowColors = colorNames.sublist(startIndex, endIndex);
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < totalRows - 1 
              ? ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing) / 2
              : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowColors.map((colorName) {
              final count = _gameState.ballCounts[colorName]!;
              final isAnimating = _animatingColor == colorName;
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.isMobile(context) ? 6.0 : 8.0),
                child: GestureDetector(
                  onTap: () => _handleColorSelection(colorName),
                  child: AnimatedBuilder(
                    animation: _ballTapAnimationController,
                    builder: (context, child) {
                      if (!isAnimating) return child!;
                      
                      // Create a horizontal transform animation
                      final animationValue = _ballTapAnimationController.value;
                      final translateX = (animationValue < 0.5 
                        ? animationValue * 2 * 10 
                        : (1 - animationValue) * 2 * 10);
                      
                      return Transform.translate(
                        offset: Offset(translateX, 0),
                        child: child,
                      );
                    },
                    child: ColorBall(
                      color: _colors[colorName]!,
                      count: count,
                      showShadow: false,
                      size: ballSize,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildModalOverlay() {
    final modalContent = ModalContentProvider.getModalContent(_activeModal);
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _modalAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _modalAnimationController.value,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: SafeArea(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _modalAnimationController,
                    builder: (context, child) {
                      final scale = AppConstants.modalScaleMin + 
                          (_modalAnimationController.value * (AppConstants.modalScaleMax - AppConstants.modalScaleMin));
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: ResponsiveUtils.getModalPadding(context),
                      child: ModalContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              modalContent.icon, 
                              style: TextStyle(fontSize: ResponsiveUtils.getModalIconSize(context))
                            ),
                            SizedBox(height: ResponsiveUtils.getGameElementSpacing(context)),
                            Text(
                              modalContent.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppConstants.primaryFontFamily,
                                fontSize: ResponsiveUtils.getTitleFontSize(context),
                                fontWeight: AppConstants.boldWeight,
                                color: AppConstants.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 15)),
                            Text(
                              modalContent.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppConstants.secondaryFontFamily,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                color: AppConstants.textTertiaryColor,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, AppConstants.extraLargeSpacing)),
                            ModalButton(
                              text: modalContent.buttonText,
                              color: modalContent.buttonColor,
                              onPressed: () => _onModalAction(modalContent.action),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
