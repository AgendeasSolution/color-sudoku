import 'package:flutter/material.dart';

/// Utility class for responsive design across mobile and tablet devices
class ResponsiveUtils {
  // Device size breakpoints
  static const double smallMobile = 360.0;
  static const double mediumMobile = 400.0;
  static const double largeMobile = 480.0;
  static const double smallTablet = 600.0;
  static const double mediumTablet = 768.0;
  static const double largeTablet = 1024.0;
  
  /// Get screen width
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  
  /// Get screen height
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) => width(context) < smallTablet;
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) => width(context) >= smallTablet;
  
  /// Check if device is small mobile
  static bool isSmallMobile(BuildContext context) => width(context) <= smallMobile;
  
  /// Check if device is medium/large mobile
  static bool isMediumOrLargeMobile(BuildContext context) => 
      width(context) > smallMobile && width(context) < smallTablet;
  
  /// Check if device is small tablet
  static bool isSmallTablet(BuildContext context) => 
      width(context) >= smallTablet && width(context) < mediumTablet;
  
  /// Check if device is medium tablet
  static bool isMediumTablet(BuildContext context) => 
      width(context) >= mediumTablet && width(context) < largeTablet;
  
  /// Check if device is large tablet
  static bool isLargeTablet(BuildContext context) => width(context) >= largeTablet;
  
  /// Get responsive value based on device size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T smallMobile,
    required T mediumMobile,
    required T largeMobile,
    required T tablet,
  }) {
    final w = width(context);
    if (w <= ResponsiveUtils.smallMobile) return smallMobile;
    if (w <= ResponsiveUtils.mediumMobile) return mediumMobile;
    if (w <= ResponsiveUtils.largeMobile) return largeMobile;
    return tablet;
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      mediumMobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      largeMobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }
  
  /// Get responsive fontSize
  static double getResponsiveFontSize(BuildContext context, {
    required double smallMobile,
    required double mediumMobile,
    required double largeMobile,
    required double tablet,
  }) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: smallMobile,
      mediumMobile: mediumMobile,
      largeMobile: largeMobile,
      tablet: tablet,
    );
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 18,
      mediumMobile: 20,
      largeMobile: 22,
      tablet: 24,
    );
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isSmallTablet(context)) {
      return baseSpacing * 1.2;
    } else if (isMediumTablet(context)) {
      return baseSpacing * 1.5;
    } else {
      return baseSpacing * 1.8;
    }
  }
  
  /// Get responsive grid cross axis count for level grid
  static int getLevelGridCrossAxisCount(BuildContext context) {
    return getResponsiveValue<int>(
      context: context,
      smallMobile: 3,
      mediumMobile: 3,
      largeMobile: 4,
      tablet: 4,
    );
  }
  
  /// Get responsive ball size
  static double getBallSize(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 35,
      mediumMobile: 40,
      largeMobile: 45,
      tablet: 50,
    );
  }
  
  /// Get responsive logo font size
  static double getLogoFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 28,
      mediumMobile: 32,
      largeMobile: 36,
      tablet: 38,
    );
  }
  
  /// Get responsive title font size
  static double getTitleFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 18,
      mediumMobile: 20,
      largeMobile: 22,
      tablet: 28,
    );
  }
  
  /// Get responsive body font size
  static double getBodyFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 13,
      mediumMobile: 14,
      largeMobile: 16,
      tablet: 18,
    );
  }
  
  /// Get responsive subtitle font size
  static double getSubtitleFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 13,
      mediumMobile: 14,
      largeMobile: 16,
      tablet: 18,
    );
  }
  
  /// Get responsive button padding
  static EdgeInsets getButtonPadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      mediumMobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      largeMobile: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  /// Get responsive solution button padding
  static EdgeInsets getSolutionButtonPadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      mediumMobile: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      largeMobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      tablet: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
  
  /// Get responsive level card font size
  static double getLevelCardFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 20,
      mediumMobile: 24,
      largeMobile: 26,
      tablet: 28,
    );
  }
  
  /// Get responsive level card grid size font
  static double getLevelGridSizeFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 10,
      mediumMobile: 11,
      largeMobile: 12,
      tablet: 12,
    );
  }
  
  /// Get responsive modal padding
  static EdgeInsets getModalPadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.all(20),
      mediumMobile: const EdgeInsets.all(24),
      largeMobile: const EdgeInsets.all(28),
      tablet: const EdgeInsets.all(30),
    );
  }
  
  /// Get responsive modal icon size
  static double getModalIconSize(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 48,
      mediumMobile: 56,
      largeMobile: 60,
      tablet: 64,
    );
  }
  
  /// Get responsive cell spacing
  static double getCellSpacing(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 1.5,
      mediumMobile: 1.8,
      largeMobile: 2.0,
      tablet: 2.0,
    );
  }
  
  /// Get responsive grid padding
  static double getGridPadding(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 3,
      mediumMobile: 3.5,
      largeMobile: 4,
      tablet: 4,
    );
  }
  
  /// Get responsive spacing between game elements
  static double getGameElementSpacing(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 12,
      mediumMobile: 16,
      largeMobile: 20,
      tablet: 20,
    );
  }
  
  /// Get responsive top nav bar padding
  static EdgeInsets getTopNavBarPadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.symmetric(horizontal: 4),
      mediumMobile: const EdgeInsets.symmetric(horizontal: 4),
      largeMobile: const EdgeInsets.symmetric(horizontal: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
  
  /// Get responsive solution button font size
  static double getSolutionButtonFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 11,
      mediumMobile: 12,
      largeMobile: 13,
      tablet: 14,
    );
  }
  
  /// Get responsive solution button top position
  static double getSolutionButtonTopPosition(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      smallMobile: 60,
      mediumMobile: 70,
      largeMobile: 80,
      tablet: 85,
    );
  }
  
  /// Get responsive ball count font size
  static double getBallCountFontSize(BuildContext context) {
    return getResponsiveFontSize(
      context,
      smallMobile: 12,
      mediumMobile: 14,
      largeMobile: 16,
      tablet: 18,
    );
  }
  
  /// Get responsive color palette padding
  static EdgeInsets getColorPalettePadding(BuildContext context) {
    return getResponsiveValue<EdgeInsets>(
      context: context,
      smallMobile: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      mediumMobile: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      largeMobile: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

