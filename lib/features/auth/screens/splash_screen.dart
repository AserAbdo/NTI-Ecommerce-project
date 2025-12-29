import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../onboarding/services/onboarding_service.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _floatingItemsController;
  late AnimationController _shineController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressFadeAnimation;
  late Animation<double> _shineAnimation;

  final List<FloatingItem> _floatingItems = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateFloatingItems();
    _startAnimations();
    _checkAuth();
  }

  void _setupAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Progress indicator animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );

    // Floating items animation
    _floatingItemsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Shine effect
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  void _generateFloatingItems() {
    final random = math.Random();
    final icons = [
      Icons.shopping_bag_outlined,
      Icons.shopping_cart_outlined,
      Icons.local_shipping_outlined,
      Icons.card_giftcard_outlined,
      Icons.favorite_border,
      Icons.star_border,
    ];

    for (int i = 0; i < 15; i++) {
      _floatingItems.add(
        FloatingItem(
          icon: icons[random.nextInt(icons.length)],
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 20 + 25,
          speed: random.nextDouble() * 0.3 + 0.15,
          opacity: random.nextDouble() * 0.3 + 0.15,
          rotation: random.nextDouble() * math.pi * 2,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        ),
      );
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _floatingItemsController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else if (state is AuthUnauthenticated) {
          // Check if onboarding should be shown
          final shouldShowOnboarding =
              await OnboardingService.shouldShowOnboarding();
          if (context.mounted) {
            if (shouldShowOnboarding) {
              Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.85),
                AppColors.primary.withOpacity(0.75),
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated floating e-commerce items
              AnimatedBuilder(
                animation: _floatingItemsController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: FloatingItemsPainter(
                      items: _floatingItems,
                      progress: _floatingItemsController.value,
                    ),
                  );
                },
              ),

              // Background effects
              _buildBackgroundEffects(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with shopping bag icon
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 50,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            // Middle container with border
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Inner container with logo
                            Container(
                              width: 140,
                              height: 140,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getSpacing(context, 40)),

                    // App name with shine effect
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            // Vendora text with shine
                            AnimatedBuilder(
                              animation: _shineAnimation,
                              builder: (context, child) {
                                return ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: const [
                                        Colors.white,
                                        Colors.white70,
                                        Colors.white,
                                      ],
                                      stops: [
                                        _shineAnimation.value - 0.3,
                                        _shineAnimation.value,
                                        _shineAnimation.value + 0.3,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    'Vendora',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.getTitleFontSize(
                                            context,
                                          ) +
                                          12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 25,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 12),
                            ),

                            // Tagline
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Your Premium Shopping Destination',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getBodyFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.95),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getSpacing(context, 60)),

                    // Custom loading indicator
                    FadeTransition(
                      opacity: _progressFadeAnimation,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background ring
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  value: 1.0,
                                ),
                              ),
                              // Animated progress
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getSpacing(context, 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Loading amazing deals',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getBodyFontSize(
                                          context,
                                        ) -
                                        1,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom branding
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 1,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Premium Quality',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize:
                                    ResponsiveHelper.getBodyFontSize(context) -
                                    3,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 1,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Version 1.0.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize:
                              ResponsiveHelper.getBodyFontSize(context) - 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        // Top left blob
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom right blob
        Positioned(
          bottom: -200,
          right: -200,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Center subtle glow
        Center(
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Floating item class for e-commerce icons
class FloatingItem {
  final IconData icon;
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  double rotation;
  final double rotationSpeed;

  FloatingItem({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
  });
}

// Custom painter for floating e-commerce items
class FloatingItemsPainter extends CustomPainter {
  final List<FloatingItem> items;
  final double progress;

  FloatingItemsPainter({required this.items, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var item in items) {
      // Update position
      item.y -= item.speed * 0.01;
      if (item.y < -0.1) {
        item.y = 1.1;
        item.x = math.Random().nextDouble();
      }

      // Update rotation
      item.rotation += item.rotationSpeed;

      // Draw icon
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      textPainter.text = TextSpan(
        text: String.fromCharCode(item.icon.codePoint),
        style: TextStyle(
          fontSize: item.size,
          fontFamily: item.icon.fontFamily,
          color: Colors.white.withOpacity(item.opacity),
        ),
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(item.x * size.width, item.y * size.height);
      canvas.rotate(item.rotation);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FloatingItemsPainter oldDelegate) => true;
}
