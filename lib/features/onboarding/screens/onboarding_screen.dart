import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/onboarding_item.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _floatingIconsController;

  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Discover',
      description: 'Top brands. Smart search. Endless possibilities.',
      icon: Icons.explore_rounded,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primary.withValues(alpha: 0.7),
    ),
    OnboardingItem(
      title: 'Shop Effortlessly',
      description: 'One tap. Your cart. Done.',
      icon: Icons.shopping_cart_rounded,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primary.withValues(alpha: 0.7),
    ),
    OnboardingItem(
      title: 'Fast & Secure',
      description: 'Quick delivery. Safe payments. Peace of mind.',
      icon: Icons.verified_user_rounded,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primary.withValues(alpha: 0.7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimationController.dispose();
    _contentAnimationController.dispose();
    _floatingIconsController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentItem = _items[_currentPage];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark mode colors
    final darkPrimaryColor = const Color(0xFF1A1A2E);
    final darkSecondaryColor = const Color(0xFF0F3460);

    // Get colors based on theme
    final primaryColor = isDark ? darkPrimaryColor : currentItem.primaryColor;
    final secondaryColor = isDark
        ? darkSecondaryColor
        : currentItem.secondaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      Color.lerp(primaryColor, secondaryColor, 0.5)!,
                      secondaryColor,
                    ],
                    transform: GradientRotation(
                      _backgroundAnimationController.value * 2 * math.pi,
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating particles/shapes
          ..._buildFloatingElements(size),

          // Background decorative shapes
          _buildBackgroundShapes(),

          // Main content - with padding for status bar
          Column(
            children: [
              // Skip button with top padding for status bar
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                  ),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page view content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildPage(index);
                  },
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final item = _items[index];
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive sizes
    final iconContainerSize = isVerySmallScreen
        ? 120.0
        : (isSmallScreen ? 150.0 : 180.0);
    final iconSize = isVerySmallScreen ? 50.0 : (isSmallScreen ? 65.0 : 80.0);
    final ringSize = iconContainerSize - 20;
    final titleFontSize = isVerySmallScreen
        ? 22.0
        : (isSmallScreen ? 26.0 : 32.0);
    final descFontSize = isVerySmallScreen
        ? 13.0
        : (isSmallScreen ? 14.0 : 16.0);
    final spacing = isVerySmallScreen ? 30.0 : (isSmallScreen ? 40.0 : 60.0);
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;

    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _contentAnimationController,
                curve: Curves.easeOutCubic,
              ),
            );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.easeIn,
          ),
        );

        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.elasticOut,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon container
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: isDark
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                          if (!isDark)
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated ring
                          AnimatedBuilder(
                            animation: _floatingIconsController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle:
                                    _floatingIconsController.value *
                                    2 *
                                    math.pi,
                                child: Container(
                                  width: ringSize,
                                  height: ringSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : item.primaryColor.withValues(
                                              alpha: 0.3,
                                            ),
                                      width: 2,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: DottedCirclePainter(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : item.primaryColor.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Main icon
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDark
                                  ? [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.7),
                                    ]
                                  : [item.primaryColor, item.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Icon(
                              item.icon,
                              size: iconSize,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Title
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 20),

                  // Description
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: descFontSize,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isSmallScreen = screenHeight < 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = isSmallScreen ? 20.0 : 32.0;
    final buttonHeight = isSmallScreen ? 54.0 : 64.0;
    final buttonWidth = _currentPage == _items.length - 1
        ? (isSmallScreen ? 160.0 : 200.0)
        : (isSmallScreen ? 54.0 : 64.0);

    return Container(
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        top: padding,
        bottom: padding + bottomPadding,
      ),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => _buildPageIndicator(index),
            ),
          ),

          SizedBox(height: isSmallScreen ? 20 : 32),

          // Next/Get Started button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                border: isDark
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: _currentPage == _items.length - 1
                    ? Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        size: isSmallScreen ? 24 : 28,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    final random = math.Random(42); // Fixed seed for consistent positions

    return List.generate(12, (index) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final elementSize = random.nextDouble() * 40 + 20;
      final opacity = random.nextDouble() * 0.15 + 0.05;

      return AnimatedBuilder(
        animation: _floatingIconsController,
        builder: (context, child) {
          final yOffset =
              math.sin(_floatingIconsController.value * 2 * math.pi + index) *
              30;
          final xOffset =
              math.cos(
                _floatingIconsController.value * 2 * math.pi + index * 0.5,
              ) *
              15;

          return Positioned(
            left: startX + xOffset,
            top: startY + yOffset,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: elementSize,
                height: elementSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: index % 3 != 0
                      ? BorderRadius.circular(elementSize * 0.2)
                      : null,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: -80,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for dotted circle around the icon
class DottedCirclePainter extends CustomPainter {
  final Color color;

  DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const dotCount = 12;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
