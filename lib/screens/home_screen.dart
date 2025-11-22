import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../services/level_progression_service.dart';
import '../services/audio_service.dart';
import '../widgets/components/game_button.dart';
import '../widgets/components/ad_banner.dart';
import '../widgets/components/gradient_logo.dart';
import '../widgets/modals/startup_modal.dart';
import '../utils/responsive_utils.dart';

// Custom painter for star pattern on completed levels
class StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;

    // Draw small stars around the center
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi) / 8;
      final starCenter = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      _drawStar(canvas, starCenter, 3, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final outerRadius = radius;
    final innerRadius = radius * 0.4;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi) / 5 - pi / 2;
      final outerX = center.dx + cos(angle) * outerRadius;
      final outerY = center.dy + sin(angle) * outerRadius;
      final innerAngle = angle + pi / 5;
      final innerX = center.dx + cos(innerAngle) * innerRadius;
      final innerY = center.dy + sin(innerAngle) * innerRadius;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  final Function(int) onLevelSelected;
  final VoidCallback? onOtherGameSelected;

  const HomeScreen({
    super.key,
    required this.onLevelSelected,
    this.onOtherGameSelected,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showHowToPlayModal = false;
  late final AnimationController _bgAnimationController;
  late final AnimationController _modalAnimationController;
  
  // Level progression state
  List<int> _unlockedLevels = [0]; // Only level 1 unlocked by default
  List<int> _completedLevels = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    _loadLevelProgression();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await AudioService().initialize();
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
  }

  Future<void> _loadLevelProgression() async {
    final unlockedLevels = await LevelProgressionService.getUnlockedLevels();
    final completedLevels = await LevelProgressionService.getCompletedLevels();
    
    if (mounted) {
      setState(() {
        _unlockedLevels = unlockedLevels;
        _completedLevels = completedLevels;
      });
    }
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _modalAnimationController.dispose();
    super.dispose();
  }

  void _showHowToPlay() {
    AudioService().playButtonClick();
    setState(() => _showHowToPlayModal = true);
    _modalAnimationController.forward(from: 0.0);
  }

  void _hideHowToPlay() {
    AudioService().playButtonClick();
    _modalAnimationController.reverse().then((_) {
      setState(() => _showHowToPlayModal = false);
    });
  }

  void _startLevel(int levelIndex) {
    widget.onLevelSelected(levelIndex);
  }

  // Method to refresh level progression (can be called when returning from game)
  Future<void> refreshLevelProgression() async {
    await _loadLevelProgression();
  }

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
                // Main content that can scroll
                Stack(
                  children: [
                    _buildAnimatedBackground(),
                    SafeArea(
                      child: _buildHomeContent(),
                    ),
                  ],
                ),
                // Ad banner positioned at bottom, transparent
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AdBanner(),
                ),
                if (_showHowToPlayModal) _buildHowToPlayModal(),
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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            child: _buildLogo(),
          ),
          SizedBox(height: ResponsiveUtils.getGameElementSpacing(context)),
          // Level Grid
          _buildLevelGrid(),
          // Action Buttons (How to Play and Sound)
          _buildActionButtons(),
          // Explore More Games Section
          _buildExploreMoreGamesSection(),
          // Bottom padding to prevent content from being hidden behind ad banner (60px ad height + some spacing)
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.getResponsiveSpacing(context, 32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHowToPlayButton(),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          _buildSoundToggleButton(),
        ],
      ),
    );
  }

  void _toggleSound() {
    AudioService().playButtonClick();
    setState(() {
      if (AudioService().isSoundEnabled()) {
        AudioService().disableSound();
      } else {
        AudioService().enableSound();
      }
    });
  }

  Widget _buildSoundToggleButton() {
    final isSoundEnabled = AudioService().isSoundEnabled();
    
    return GameIconButton(
      icon: isSoundEnabled ? Icons.volume_up : Icons.volume_off,
      color: AppConstants.primaryAccentColor,
      onPressed: _toggleSound,
    );
  }

  Widget _buildLogo() {
    return GradientLogo(
      fontSize: ResponsiveUtils.getLogoFontSize(context),
      subtitleFontSize: ResponsiveUtils.getSubtitleFontSize(context),
    );
  }

  Widget _buildLevelGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        childAspectRatio: ResponsiveUtils.isTablet(context) ? 0.95 : 0.85,
      ),
      itemCount: AppConstants.levelConfig.length,
      itemBuilder: (context, index) {
        return _buildLevelButton(index);
      },
    );
  }

  Widget _buildLevelButton(int levelIndex) {
    // Bounds checking for level config
    if (levelIndex < 0 || levelIndex >= AppConstants.levelConfig.length) {
      return const SizedBox.shrink();
    }
    
    final level = AppConstants.levelConfig[levelIndex];
    final isUnlocked = _unlockedLevels.contains(levelIndex);
    final isCompleted = _completedLevels.contains(levelIndex);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: isUnlocked ? () {
          AudioService().playButtonClick();
          _startLevel(levelIndex);
        } : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _getLevelCardGradient(isUnlocked, isCompleted),
            border: Border.all(
              color: _getLevelCardBorderColor(isUnlocked, isCompleted),
              width: 2,
            ),
            boxShadow: _getLevelCardShadows(isUnlocked, isCompleted),
          ),
          child: Stack(
            children: [
              // Background pattern for completed levels
              if (isCompleted) _buildCompletedLevelPattern(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Level number - plain text with enhanced styling
                    Text(
                      '${levelIndex + 1}',
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFontFamily,
                        fontSize: ResponsiveUtils.getLevelCardFontSize(context),
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? Colors.white : Colors.grey.shade400,
                        shadows: isUnlocked ? [
                          const Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                          ),
                        ] : null,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    
                    // Grid size - plain text with safe access
                    Text(
                      '${level['gridSize'] ?? '?'}×${level['gridSize'] ?? '?'}',
                      style: TextStyle(
                        fontFamily: AppConstants.secondaryFontFamily,
                        fontSize: ResponsiveUtils.getLevelGridSizeFontSize(context),
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? Colors.white.withOpacity(0.9) : Colors.grey.shade400,
                        shadows: isUnlocked ? [
                          const Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ] : null,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status indicators
              _buildLevelStatusIndicators(isUnlocked, isCompleted),
              
              // Glow effect for unlocked levels
              if (isUnlocked && !isCompleted) _buildUnlockedGlowEffect(),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getLevelCardGradient(bool isUnlocked, bool isCompleted) {
    if (isCompleted) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4CAF50), // Success green
          Color(0xFF8BC34A), // Light green
          Color(0xFF4CAF50), // Success green
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else if (isUnlocked) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2196F3), // Primary blue
          Color(0xFF21CBF3), // Light blue
          Color(0xFF2196F3), // Primary blue
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2D3748), // Dark grey
          Color(0xFF1A202C), // Darker grey
        ],
      );
    }
  }

  Color _getLevelCardBorderColor(bool isUnlocked, bool isCompleted) {
    if (isCompleted) {
      return const Color(0xFF4CAF50).withOpacity(0.8);
    } else if (isUnlocked) {
      return const Color(0xFF2196F3).withOpacity(0.8);
    } else {
      return const Color(0xFF4A5568).withOpacity(0.5);
    }
  }

  List<BoxShadow> _getLevelCardShadows(bool isUnlocked, bool isCompleted) {
    if (isCompleted) {
      return [
        BoxShadow(
          color: const Color(0xFF4CAF50).withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 4,
          offset: const Offset(0, 16),
        ),
      ];
    } else if (isUnlocked) {
      return [
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          blurRadius: 30,
          spreadRadius: 2,
          offset: const Offset(0, 12),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }

  Widget _buildCompletedLevelPattern() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          painter: StarPatternPainter(),
        ),
      ),
    );
  }

  Widget _buildLevelStatusIndicators(bool isUnlocked, bool isCompleted) {
    return Stack(
      children: [
        // Lock icon for locked levels
        if (!isUnlocked)
          Positioned(
            top: ResponsiveUtils.getResponsiveSpacing(context, 8),
            right: ResponsiveUtils.getResponsiveSpacing(context, 8),
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 4)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveSpacing(context, 8)
                ),
              ),
              child: Icon(
                Icons.lock,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        
        // Success indicator for completed levels
        if (isCompleted)
          Positioned(
            top: ResponsiveUtils.getResponsiveSpacing(context, 8),
            right: ResponsiveUtils.getResponsiveSpacing(context, 8),
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 4)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveSpacing(context, 8)
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.star,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnlockedGlowEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              const Color(0xFF2196F3).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowToPlayButton() {
    return GameIconButton(
      icon: Icons.help_outline,
      color: AppConstants.warningColor,
      onPressed: _showHowToPlay,
    );
  }

  Widget _buildHowToPlayModal() {
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
                    child: StartupModal(
                      onClose: _hideHowToPlay,
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

  Widget _buildExploreMoreGamesSection() {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.getResponsiveSpacing(context, 24),
      ),
      child: Column(
        children: [
          _buildExploreMoreGamesHeading(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          _buildGameButtonsRow(),
        ],
      ),
    );
  }

  Widget _buildExploreMoreGamesHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
          color: AppConstants.logoPurple,
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 6)),
        Text(
          'Explore More Games',
          style: TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: ResponsiveUtils.getBodyFontSize(context) * 1.2,
            fontWeight: AppConstants.semiBoldWeight,
            color: AppConstants.logoPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMobileGamesButton(),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        _buildWebGamesButton(),
      ],
    );
  }

  Widget _buildMobileGamesButton() {
    return GameButton(
      iconData: Icons.phone_android,
      text: 'Mobile Games',
      color: const Color(0xFF9F7AEA), // Vibrant purple matching game theme
      onPressed: () {
        AudioService().playButtonClick();
        widget.onOtherGameSelected?.call();
      },
    );
  }

  Widget _buildWebGamesButton() {
    return GameButton(
      iconData: Icons.laptop,
      text: 'Web Games',
      color: const Color(0xFF2196F3), // Blue matching unlocked level buttons
      onPressed: () async {
        AudioService().playButtonClick();
        try {
          final url = Uri.parse('https://freegametoplay.com');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          // Silently handle errors - user can manually navigate if needed
        }
      },
    );
  }
}
