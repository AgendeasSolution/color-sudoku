import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';
import '../widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onSplashComplete;

  const SplashScreen({
    super.key,
    required this.onSplashComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _bgAnimationController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _textAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    _startSplashSequence();
  }

  void _initializeAnimationControllers() {
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.backgroundAnimationDuration,
    )..repeat();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _startSplashSequence() async {
    // Start logo animation
    _logoAnimationController.forward();
    
    // Wait a bit then start text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _textAnimationController.forward();
    
    // Wait for splash duration then complete
    await Future.delayed(AppConstants.splashScreenDuration);
    widget.onSplashComplete();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildSplashContent(),
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

  Widget _buildSplashContent() {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            _buildGameLogo(),
            const Spacer(),
            _buildDeveloperCredit(),
            const SizedBox(height: AppConstants.largeSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildGameLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _logoAnimationController,
          curve: Curves.easeOut,
        ));

        return FadeTransition(
          opacity: opacity,
          child: GradientLogo(
            textAlign: TextAlign.center,
            showSubtitle: true,
            fontSize: ResponsiveUtils.getLogoFontSize(context),
            subtitleFontSize: ResponsiveUtils.getSubtitleFontSize(context),
          ),
        );
      },
    );
  }


  Widget _buildDeveloperCredit() {
    return AnimatedBuilder(
      animation: _textAnimationController,
      builder: (context, child) {
        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _textAnimationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: opacity,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Developed by',
                  style: TextStyle(
                    fontFamily: AppConstants.secondaryFontFamily,
                    fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                    color: AppConstants.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 2)),
                Text(
                  'FGTP Labs',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFontFamily,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    fontWeight: AppConstants.boldWeight,
                    color: AppConstants.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
