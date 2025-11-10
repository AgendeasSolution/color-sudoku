import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppColors {
  // Background colors
  static const Color background = AppConstants.backgroundColor;
  static const Color surface = AppConstants.cardBackgroundColor;
  static const Color surfaceLight = AppConstants.cardSecondaryColor;
  
  // Text colors
  static const Color textPrimary = AppConstants.textPrimaryColor;
  static const Color textSecondary = AppConstants.textSecondaryColor;
  
  // Accent colors
  static const Color primary = AppConstants.primaryAccentColor;
  static const Color secondary = AppConstants.logoPurple;
  static const Color accent = AppConstants.warningColor;
  
  // Utility colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color border = AppConstants.borderColor;
  
  // Gradients
  static const List<Color> surfaceGradient = [
    AppConstants.cardBackgroundColor,
    AppConstants.cardSecondaryColor,
  ];
  
  static const List<Color> buttonGradient = [
    AppConstants.warningColor,
    Color(0xFFFFB84D), // Lighter yellow
  ];
}

