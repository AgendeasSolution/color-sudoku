import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class LevelBadge extends StatelessWidget {
  final int level;

  const LevelBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.extraLargeSpacing,
        vertical: AppConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.levelBadgeBorderRadius),
        border: Border.all(
          color: AppConstants.primaryAccentColor,
          width: AppConstants.cellBorderWidth,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppConstants.cardBackgroundColor, AppConstants.cardSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryAccentColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: AppConstants.mediumIconSize)),
          const SizedBox(width: 10),
          Text(
            'Level $level',
            style: const TextStyle(
              fontFamily: AppConstants.primaryFontFamily,
              fontSize: AppConstants.levelBadgeFontSize,
              fontWeight: AppConstants.boldWeight,
              color: AppConstants.primaryAccentColor,
              shadows: [
                Shadow(
                  color: AppConstants.primaryAccentColor,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
