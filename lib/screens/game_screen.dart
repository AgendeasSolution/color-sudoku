import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/cell_position.dart';
import '../models/game_state.dart';
import '../models/modal_types.dart';
import '../services/game_logic_service.dart';
import '../services/solver_service.dart';
import '../services/level_progression_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/rewarded_ad_service.dart';
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
  CellPosition? _shakingCell;

  // UI State
  ModalType _activeModal = ModalType.none;
  bool _solutionShown = false;
  bool _solutionAnimating = false;
  bool _justWatchedSolutionAd = false; // Track if user just watched ad for solution

  // Animation Controllers
  late final AnimationController _bgAnimationController;
  late final AnimationController _modalAnimationController;
  late final AnimationController _shakeAnimationController;

  // Key to access GridView state for animations
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    _startLevel(widget.initialLevel);
    // Preload ads for better user experience
    InterstitialAdService.instance.preloadAd();
    RewardedAdService.instance.preloadAd();
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
      duration: AppConstants.shakeAnimationDuration,
    );
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _modalAnimationController.dispose();
    _shakeAnimationController.dispose();
    super.dispose();
  }

  // --- Game Logic ---

  void _startLevel(int levelIndex) {
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) return;

    setState(() {
      _gameState = GameLogicService.initializeGame(levelIndex);
      _colors = ColorUtils.getColorsForLevel(_gameState.colorNames);
      _solutionShown = false; // Reset solution shown state for new level
      _justWatchedSolutionAd = false; // Reset solution ad flag for new level
    });
  }

  /// Restart level with interstitial ad (50% probability)
  Future<void> _restartLevelWithAd(int levelIndex) async {
    // Try to show interstitial ad with 50% probability
    final adShown = await InterstitialAdService.instance.showAdWithProbability(
      onAdDismissed: () {
        // This callback is called when ad is dismissed
        _startLevel(levelIndex);
        // Preload next ad for future use
        InterstitialAdService.instance.preloadAd();
      },
    );

    // If ad was not shown (50% chance), restart immediately
    if (!adShown) {
      _startLevel(levelIndex);
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
      _showInvalidMoveWarning(_gameState.path[_gameState.currentStep]);
      return;
    }

    setState(() {
      _gameState = GameLogicService.placeBall(_gameState, color);
      
      if (ValidationUtils.isGameComplete(_gameState)) {
        _winGame();
      } else if (ValidationUtils.isGameOver(_gameState)) {
        _gameOver();
      }
    });
  }

  void _winGame() async {
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
    setState(() {
      _gameState = _gameState.copyWith(isGameOver: true);
    });
    _showModal(ModalType.gameOver);
  }

  // --- Solver Logic ---

  Future<void> _showSolution() async {
    print('=== SOLUTION BUTTON PRESSED ===');
    print('Level: ${_gameState.currentLevel}');
    print('Grid Size: ${_gameState.gridSize}');
    print('Colors: ${_gameState.colorNames}');
    print('Current step: ${_gameState.currentStep}');
    
    // Show rewarded ad first - reward-based system
    final adShown = await RewardedAdService.instance.showAdAlways(
      onAdDismissed: () {
        // This callback is called when ad is dismissed
        // Only execute solution if reward was actually earned
        if (RewardedAdService.instance.wasRewardEarned) {
          print('Reward earned! Executing solution...');
          // Set flag to indicate user just watched ad for solution
          _justWatchedSolutionAd = true;
          _executeSolution();
        } else {
          print('No reward earned. Solution not provided.');
          // Show message that user needs to watch full ad
          _showRewardRequiredMessage();
        }
        // Preload next ad for future use
        RewardedAdService.instance.preloadAd();
      },
      onRewardEarned: () {
        // This callback is called when user earns reward
        print('User earned reward for solution!');
        // Solution will be executed in onAdDismissed callback if reward was earned
      },
    );

    // If ad failed to load, still provide solution (graceful fallback)
    if (!adShown) {
      _executeSolution();
      // Preload next ad for future use
      RewardedAdService.instance.preloadAd();
    }
  }

  void _showRewardRequiredMessage() {
    // Show a brief message that user needs to watch full ad
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please watch the full ad to earn the solution!',
          style: TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontWeight: AppConstants.boldWeight,
          ),
        ),
        backgroundColor: AppConstants.warningColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _executeSolution() async {
    // Hide button immediately when ad is dismissed to prevent multiple clicks
    setState(() {
      _solutionShown = true;
      _solutionAnimating = true;
    });
    
    try {
      print('Starting solver with current board state...');
      final solutionSteps = await SolverService.solveGame(_gameState);
      print('Solver returned ${solutionSteps.length} steps');

      if (solutionSteps.isNotEmpty) {
        print('Solution found, applying remaining moves with animation...');
        print('Solution has ${solutionSteps.length} steps for ${_gameState.gridSize}x${_gameState.gridSize} grid');
        
        // Don't reset the game state - keep player's current moves
        // Only apply the solution steps that fill remaining empty cells
        for (int i = 0; i < solutionSteps.length; i++) {
          final step = solutionSteps[i];
          print('Applying step ${i + 1}: ${step.color} at (${step.position.row}, ${step.position.col})');
          await Future.delayed(AppConstants.solutionStepDelay);
          
          // Check if widget is still mounted before calling setState
          if (!mounted) return;
          
          setState(() {
            // Only place if the cell is currently empty
            if (_gameState.gridState[step.position.row][step.position.col] == null) {
              final newGridState = _gameState.gridState.map((row) => List<String?>.from(row)).toList();
              newGridState[step.position.row][step.position.col] = step.color;
              
              final newBallCounts = Map<String, int>.from(_gameState.ballCounts);
              newBallCounts[step.color] = newBallCounts[step.color]! - 1;
              
              final newCurrentStep = _gameState.currentStep + 1;
              final isGameOver = newCurrentStep == _gameState.gridSize * _gameState.gridSize;
              
              _gameState = _gameState.copyWith(
                gridState: newGridState,
                ballCounts: newBallCounts,
                currentStep: newCurrentStep,
                isGameOver: isGameOver,
              );
            }
          });
        }
        
        // Wait 4 seconds after all cells are filled, then show modal
        await Future.delayed(const Duration(seconds: 4));
        
        // Check if widget is still mounted before showing modal
        if (!mounted) return;
        
        setState(() {
          _solutionAnimating = false;
        });
        
        print('Solution complete, showing modal');
        _showModal(ModalType.solutionComplete);
      } else {
        print('No solution found');
        if (mounted) {
          setState(() {
            _solutionAnimating = false;
          });
          _showModal(ModalType.noSolution);
        }
      }
    } catch (e) {
      print('ERROR in solution: $e');
      if (mounted) {
        setState(() {
          _solutionAnimating = false;
        });
        _showModal(ModalType.noSolution);
      }
    }
  }

  // --- UI and Animation Methods ---

  void _showInvalidMoveWarning(CellPosition pos) {
    setState(() => _shakingCell = pos);
    _shakeAnimationController.forward(from: 0.0);
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
          // Check if user just watched solution ad - skip interstitial if so
          if (_justWatchedSolutionAd) {
            print('User just watched solution ad, skipping interstitial ad for play again');
            _startLevel(_gameState.currentLevel);
            _justWatchedSolutionAd = false; // Reset the flag
          } else {
            _restartLevelWithAd(_gameState.currentLevel);
          }
          break;
        case ModalAction.close:
          // just close
          break;
      }
    });
  }

  /// Exit to home with interstitial ad (50% probability)
  Future<void> _goHomeWithAd() async {
    // Check if ad is ready first to avoid loading delays
    if (InterstitialAdService.instance.isAdReady) {
      // Try to show interstitial ad with 50% probability
      final adShown = await InterstitialAdService.instance.showAdWithProbability(
        onAdDismissed: () {
          // This callback is called when ad is dismissed - exit immediately
          widget.onGoHome();
          // Preload next ad for future use
          InterstitialAdService.instance.preloadAd();
        },
      );

      // If ad was not shown (50% chance), exit immediately
      if (!adShown) {
        widget.onGoHome();
        // Preload next ad for future use
        InterstitialAdService.instance.preloadAd();
      }
    } else {
      // No ad ready, exit immediately without delay
      widget.onGoHome();
      // Preload next ad for future use
      InterstitialAdService.instance.preloadAd();
    }
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
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
        // Solution button - positioned below nav bar (will be handled in _buildSolutionButton)
        _buildSolutionButton(),
        // Centered game elements - truly centered on screen
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGameGrid(),
              SizedBox(height: ResponsiveUtils.getGameElementSpacing(context)),
              _buildColorPalette(),
            ],
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
            onTap: _goHomeWithAd,
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
          const Spacer(),
          // Level text (center) - no border or icon
          Text(
            'Level ${_gameState.currentLevel + 1}',
            style: TextStyle(
              fontFamily: AppConstants.primaryFontFamily,
              fontSize: ResponsiveUtils.getTitleFontSize(context),
              fontWeight: AppConstants.boldWeight,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const Spacer(),
          // Reset button (right) - icon only
          GestureDetector(
            onTap: () => _restartLevelWithAd(_gameState.currentLevel),
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing)
              ),
              decoration: BoxDecoration(
                color: AppConstants.errorColor,
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
              child: Icon(
                Icons.refresh,
                color: AppConstants.textPrimaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionButton() {
    // Hide solution button if solution has already been shown
    if (_solutionShown) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: ResponsiveUtils.getSolutionButtonTopPosition(context),
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _showSolution,
          child: Container(
            padding: ResponsiveUtils.getSolutionButtonPadding(context),
            decoration: BoxDecoration(
              color: AppConstants.warningColor,
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎁',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing),
                ),
                Text(
                  'Watch Ad for Solution',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFontFamily,
                    fontSize: ResponsiveUtils.getSolutionButtonFontSize(context),
                    fontWeight: AppConstants.boldWeight,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
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

                    Widget cell = GridCell(
                      color: colorName != null ? _colors[colorName] : null,
                      isNext: isNextCell,
                    );

                    if (_shakingCell?.row == row && _shakingCell?.col == col) {
                      return AnimatedBuilder(
                        animation: _shakeAnimationController,
                        builder: (context, child) {
                          double offset = sin(_shakeAnimationController.value * 2 * pi) * AppConstants.shakeAmplitude;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
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
              // Block all colors when solution is animating, otherwise use normal logic
              final isEnabled = _solutionAnimating ? false : (count > 0 && !invalidColors.contains(colorName));
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.isMobile(context) ? 2.0 : 4.0),
                child: GestureDetector(
                  onTap: isEnabled ? () => _handleColorSelection(colorName) : null,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.4,
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
