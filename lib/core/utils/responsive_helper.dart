import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Mobile size breakpoints for granular control
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 414;
  }

  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 414 && width < 600;
  }

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

  // Responsive padding - now with granular mobile support
  static double getHorizontalPadding(BuildContext context) {
    if (isSmallMobile(context)) return 12.0;
    if (isMediumMobile(context)) return 16.0;
    if (isLargeMobile(context)) return 20.0;
    if (isTablet(context)) return 48.0;
    return 64.0;
  }

  static double getVerticalPadding(BuildContext context) {
    if (isSmallMobile(context)) return 16.0;
    if (isMediumMobile(context)) return 20.0;
    if (isLargeMobile(context)) return 24.0;
    if (isTablet(context)) return 32.0;
    return 48.0;
  }

  // Responsive font sizes - now with granular mobile support
  static double getTitleFontSize(BuildContext context) {
    if (isSmallMobile(context)) return 22.0;
    if (isMediumMobile(context)) return 24.0;
    if (isLargeMobile(context)) return 28.0;
    if (isTablet(context)) return 32.0;
    return 36.0;
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isSmallMobile(context)) return 13.0;
    if (isMediumMobile(context)) return 14.0;
    if (isLargeMobile(context)) return 16.0;
    if (isTablet(context)) return 18.0;
    return 20.0;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isSmallMobile(context)) return 12.0;
    if (isMediumMobile(context)) return 13.0;
    if (isLargeMobile(context)) return 14.0;
    if (isTablet(context)) return 16.0;
    return 18.0;
  }

  // Greeting font size - responsive for home screen
  static double getGreetingFontSize(BuildContext context) {
    if (isSmallMobile(context)) return 20.0;
    if (isMediumMobile(context)) return 22.0;
    if (isLargeMobile(context)) return 24.0;
    if (isTablet(context)) return 28.0;
    return 32.0;
  }

  // Section header font size
  static double getSectionHeaderFontSize(BuildContext context) {
    if (isSmallMobile(context)) return 15.0;
    if (isMediumMobile(context)) return 16.0;
    if (isLargeMobile(context)) return 18.0;
    if (isTablet(context)) return 20.0;
    return 22.0;
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context) {
    if (isSmallMobile(context)) return 60.0;
    if (isMediumMobile(context)) return 70.0;
    if (isLargeMobile(context)) return 80.0;
    if (isTablet(context)) return 100.0;
    return 120.0;
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, double mobileSize) {
    if (isSmallMobile(context)) return mobileSize * 0.7;
    if (isMediumMobile(context)) return mobileSize * 0.85;
    if (isLargeMobile(context)) return mobileSize;
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

  // Grid columns (for product grids) - now responsive to screen width
  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 2;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  // Product card aspect ratio - adjusts based on screen size
  static double getProductCardAspectRatio(BuildContext context) {
    if (isSmallMobile(context)) return 0.62;
    if (isMediumMobile(context)) return 0.65;
    if (isLargeMobile(context)) return 0.68;
    if (isTablet(context)) return 0.72;
    return 0.75;
  }

  // Grid spacing
  static double getGridSpacing(BuildContext context) {
    if (isSmallMobile(context)) return 8.0;
    if (isMediumMobile(context)) return 10.0;
    if (isLargeMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }

  // Carousel height as fraction of screen height
  static double getCarouselHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    if (isSmallMobile(context)) return screenHeight * 0.18;
    if (isMediumMobile(context)) return screenHeight * 0.20;
    if (isLargeMobile(context)) return screenHeight * 0.22;
    if (isTablet(context)) return screenHeight * 0.25;
    return screenHeight * 0.28;
  }

  // Category chip height
  static double getCategoryChipHeight(BuildContext context) {
    if (isSmallMobile(context)) return 32.0;
    if (isMediumMobile(context)) return 36.0;
    if (isLargeMobile(context)) return 40.0;
    if (isTablet(context)) return 44.0;
    return 48.0;
  }

  // Category chip padding
  static EdgeInsets getCategoryChipPadding(BuildContext context) {
    if (isSmallMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
    if (isMediumMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
    }
    if (isLargeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  }

  // Product card padding
  static EdgeInsets getProductCardPadding(BuildContext context) {
    if (isSmallMobile(context)) {
      return const EdgeInsets.fromLTRB(8, 6, 8, 8);
    }
    if (isMediumMobile(context)) {
      return const EdgeInsets.fromLTRB(10, 8, 10, 10);
    }
    return const EdgeInsets.fromLTRB(12, 10, 12, 12);
  }

  // Add to cart button size
  static double getAddToCartButtonSize(BuildContext context) {
    if (isSmallMobile(context)) return 32.0;
    if (isMediumMobile(context)) return 36.0;
    if (isLargeMobile(context)) return 40.0;
    if (isTablet(context)) return 44.0;
    return 48.0;
  }

  // Add to cart icon size
  static double getAddToCartIconSize(BuildContext context) {
    if (isSmallMobile(context)) return 16.0;
    if (isMediumMobile(context)) return 18.0;
    if (isLargeMobile(context)) return 20.0;
    return 22.0;
  }

  // Search bar height
  static double getSearchBarHeight(BuildContext context) {
    if (isSmallMobile(context)) return 40.0;
    if (isMediumMobile(context)) return 44.0;
    if (isLargeMobile(context)) return 48.0;
    return 52.0;
  }

  // AppBar toolbar height
  static double getAppBarHeight(BuildContext context) {
    if (isSmallMobile(context)) return 56.0;
    if (isMediumMobile(context)) return 60.0;
    if (isLargeMobile(context)) return 65.0;
    return 70.0;
  }
}
