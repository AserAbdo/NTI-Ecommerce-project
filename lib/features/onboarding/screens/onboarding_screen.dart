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
      title: 'Discover Products',
      description:
          'Explore thousands of products from top brands. Find exactly what you\'re looking for with our smart search.',
      icon: Icons.explore_rounded,
      primaryColor: AppColors.primary,
      secondaryColor: const Color(0xFF9C27B0),
    ),
    OnboardingItem(
      title: 'Easy Shopping',
      description:
          'Add items to your cart with a single tap. Enjoy a seamless shopping experience like never before.',
      icon: Icons.shopping_cart_rounded,
      primaryColor: const Color(0xFF00BCD4),
      secondaryColor: const Color(0xFF2196F3),
    ),
    OnboardingItem(
      title: 'Fast Delivery',
      description:
          'Get your orders delivered right to your doorstep. Track your packages in real-time.',
      icon: Icons.local_shipping_rounded,
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFF5722),
    ),
    OnboardingItem(
      title: 'Secure Payments',
      description:
          'Shop with confidence using our secure payment system. Multiple payment options available.',
      icon: Icons.security_rounded,
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF009688),
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

    return Scaffold(
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
                      currentItem.primaryColor,
                      Color.lerp(
                        currentItem.primaryColor,
                        currentItem.secondaryColor,
                        0.5,
                      )!,
                      currentItem.secondaryColor,
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

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final item = _items[index];

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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon container
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
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
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: item.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: DottedCirclePainter(
                                      color: item.primaryColor.withValues(
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
                              colors: [item.primaryColor, item.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Icon(
                              item.icon,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Title
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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
                        fontSize: 16,
                        height: 1.6,
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
    return Container(
      padding: const EdgeInsets.all(32),
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

          const SizedBox(height: 32),

          // Next/Get Started button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == _items.length - 1 ? 200 : 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
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
                    ? ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _items[_currentPage].primaryColor,
                            _items[_currentPage].secondaryColor,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _items[_currentPage].primaryColor,
                            _items[_currentPage].secondaryColor,
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
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
