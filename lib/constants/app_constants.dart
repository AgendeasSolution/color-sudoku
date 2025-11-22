import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Color Sudoku';
  static const String appDescription = 'Color Puzzle Adventure';
  static const String appVersion = '1.0.2'; // Update this when version changes in pubspec.yaml
  
  // Colors
  static const Map<String, Color> allColors = {
    'red': Color(0xFFFF0000),
    'navy': Color(0xFF0F46F8),
    'green': Color(0xFF22C55E),
    'orange': Color(0xFFF97316),
    'yellow': Color(0xFF95FF00),
    'pink': Color(0xFFCB23E4),
    'brown': Color(0xFF9B521F),
    'cyan': Color(0xFF06B6D4),
    'magenta': Color(0xFFEC4899),
    'blue': Color(0xFF2255A7),
    'olive': Color(0xFF67604B),
    'white': Color(0xFFFFFFFF),
    'black': Color(0xFF000000),
  };

  // Level Configuration
  static const List<Map<String, dynamic>> levelConfig = [
    {'gridSize': 5, 'colors': ['red', 'navy', 'green', 'orange', 'yellow']},
    {'gridSize': 6, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink']},
    {'gridSize': 7, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown']},
    {'gridSize': 8, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan']},
    {'gridSize': 9, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan', 'magenta']},
    {'gridSize': 10, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan', 'magenta', 'blue']},
    {'gridSize': 11, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan', 'magenta', 'blue', 'olive']},
    {'gridSize': 12, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan', 'magenta', 'blue', 'olive', 'white']},
    {'gridSize': 13, 'colors': ['red', 'navy', 'green', 'orange', 'yellow', 'pink', 'brown', 'cyan', 'magenta', 'blue', 'olive', 'white', 'black']},
  ];

  // UI Colors
  static const Color backgroundColor = Color(0xFF101827);
  static const Color secondaryBackgroundColor = Color(0xFF0F1419);
  static const Color tertiaryBackgroundColor = Color(0xFF1A1D29);
  static const Color cardBackgroundColor = Color(0xFF2D3748);
  static const Color cardSecondaryColor = Color(0xFF1A202C);
  static const Color borderColor = Color(0xFF4A5568);
  static const Color primaryAccentColor = Color(0xFF63B3ED);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFD69E2E);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFA0AEC0);
  static const Color textTertiaryColor = Color(0xFFCBD5E0);

  // Logo Colors
  static const Color logoTextColor = Color(0xFFFFFFFF); // #ffffff (white)
  static const Color logoBlue = Color(0xFF63B3ED); // #63b3ed (blue)
  static const Color logoPurple = Color(0xFF9F7AEA); // #9f7aea (purple)
  static const Color logoOrange = Color(0xFFED8936); // #ed8936 (orange)
  static const Color logoTeal = Color(0xFF38B2AC); // #38b2ac (teal)
  static const Color logoTextShadow = Color(0xCC63B3ED); // rgba(99, 179, 237, 0.8) (blue glow)

  // Board Background Colors
  static const Color gameContainerBgStart = Color(0xFF1A202C); // #1a202c
  static const Color gameContainerBgEnd = Color(0xFF2D3748); // #2d3748
  static const Color gridCellBgStart = Color(0xFF4A5568); // #4a5568
  static const Color gridCellBgEnd = Color(0xFF2D3748); // #2d3748
  static const Color mainContainerBorder = Color(0xFF4A5568); // #4a5568
  static const Color gridCellBorder = Color(0xFF718096); // #718096

  // Animation Durations
  static const Duration backgroundAnimationDuration = Duration(seconds: 20);
  static const Duration modalAnimationDuration = Duration(milliseconds: 300);
  static const Duration modalReverseDuration = Duration(milliseconds: 200);
  static const Duration shakeAnimationDuration = Duration(milliseconds: 500);
  static const Duration solutionStepDelay = Duration(milliseconds: 75);
  static const Duration solutionCompleteDelay = Duration(milliseconds: 500);
  static const Duration modalActionDelay = Duration(milliseconds: 250);
  static const Duration splashScreenDuration = Duration(seconds: 3);

  // Grid Configuration
  static const double gridPadding = 4.0;
  static const double cellSpacing = 2.0;
  static const double cellBorderRadius = 6.0;
  static const double gridBorderRadius = 12.0;
  static const double cellBorderWidth = 2.0;

  // Button Configuration
  static const double buttonBorderRadius = 12.0;
  static const double modalButtonBorderRadius = 15.0;
  static const double levelBadgeBorderRadius = 25.0;
  static const double colorPaletteBorderRadius = 15.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 20.0;
  static const double extraLargeSpacing = 30.0;

  // Font Sizes
  static const double titleFontSize = 38.0;
  static const double subtitleFontSize = 18.0;
  static const double sectionTitleFontSize = 24.0;
  static const double bodyFontSize = 18.0;
  static const double smallFontSize = 15.0;
  static const double buttonFontSize = 18.0;
  static const double levelBadgeFontSize = 20.0;
  static const double ballCountFontSize = 18.0;

  // Font Families
  static const String primaryFontFamily = 'Roboto'; // Using system font
  static const String secondaryFontFamily = 'Roboto'; // Using system font

  // Font Weights
  static const FontWeight lightWeight = FontWeight.w300;
  static const FontWeight regularWeight = FontWeight.w400;
  static const FontWeight mediumWeight = FontWeight.w500;
  static const FontWeight semiBoldWeight = FontWeight.w600;
  static const FontWeight boldWeight = FontWeight.w700;
  static const FontWeight extraBoldWeight = FontWeight.w900;

  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 20.0;
  static const double largeIconSize = 64.0;

  // Ball Configuration
  static const double ballSize = 50.0;
  static const double ballSizeFactor = 0.8;
  static const double ballShadowBlur = 15.0;
  static const double ballShadowOffset = 4.0;

  // Modal Configuration
  static const double modalMargin = 20.0;
  static const double modalPadding = 30.0;
  static const double modalBorderRadius = 20.0;
  static const double modalBorderWidth = 2.0;
  static const double modalShadowBlur = 60.0;
  static const double modalShadowOffset = 20.0;

  // Grid Cell Configuration
  static const double cellPulseDuration = 2.0;
  static const double cellShadowBlur = 20.0;
  static const double cellShadowSpread = 0.0;
  static const double cellNextShadowBlur = 20.0;

  // Animation Values
  static const double shakeAmplitude = 8.0;
  static const double modalScaleMin = 0.95;
  static const double modalScaleMax = 1.0;
  static const double backgroundCircleSize = 400.0;
  static const double backgroundCircleOpacity = 0.15;
  static const double backgroundCircleSecondaryOpacity = 0.12;
  static const double backgroundCircleTertiaryOpacity = 0.08;
}
