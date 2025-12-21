import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Device type checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // Screen dimensions
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive padding
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return 24.0;
    if (isTablet(context)) return 48.0;
    return 64.0;
  }

  static double getVerticalPadding(BuildContext context) {
    if (isMobile(context)) return 24.0;
    if (isTablet(context)) return 32.0;
    return 48.0;
  }

  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 28.0;
    if (isTablet(context)) return 32.0;
    return 36.0;
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 18.0;
    return 20.0;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) return 14.0;
    if (isTablet(context)) return 16.0;
    return 18.0;
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 80.0;
    if (isTablet(context)) return 100.0;
    return 120.0;
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, double mobileSize) {
    if (isMobile(context)) return mobileSize;
    if (isTablet(context)) return mobileSize * 1.5;
    return mobileSize * 2;
  }

  // Form width for centered forms on tablets
  static double getFormWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) return screenWidth;
    if (isTablet(context)) return screenWidth * 0.6;
    return 500.0;
  }

  // Grid columns (for product grids later)
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
}
