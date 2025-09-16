import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ColorUtils {
  static Map<String, Color> getColorsForLevel(List<String> colorNames) {
    return {for (var name in colorNames) name: AppConstants.allColors[name]!};
  }

  static Color getColorByName(String colorName) {
    return AppConstants.allColors[colorName] ?? Colors.grey;
  }

  static bool isValidColorName(String colorName) {
    return AppConstants.allColors.containsKey(colorName);
  }

  static List<String> getAvailableColorNames() {
    return AppConstants.allColors.keys.toList();
  }
}
