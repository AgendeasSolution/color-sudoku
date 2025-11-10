import 'dart:math';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value;
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
}

