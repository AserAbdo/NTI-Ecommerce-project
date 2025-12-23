import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

class DealsCarousel extends StatefulWidget {
  const DealsCarousel({super.key});

  @override
  State<DealsCarousel> createState() => _DealsCarouselState();
}

class _DealsCarouselState extends State<DealsCarousel>
    with TickerProviderStateMixin {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _index = 0;
  Timer? _timer;
  Timer? _progressTimer;
  bool _isUserInteracting = false;
  double _progress = 0.0;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

  final List<DealData> _deals = const [
    DealData(
      image: 'assets/images/carousel-1.png',
      title: 'Special Offers',
      subtitle: 'Up to 50% OFF',
      badge: 'HOT',
      gradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DealData(
      image: 'assets/images/carousel-2.png',
      title: 'Fast Delivery',
      subtitle: 'Shop & Save',
      badge: 'NEW',
      gradient: LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFF5576c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DealData(
      image: 'assets/images/carousel-3.png',
      title: 'Winter Collection',
      subtitle: 'Stay Warm',
      badge: 'SALE',
      gradient: LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _startAutoScroll();
    _startProgress();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients && !_isUserInteracting) {
        int nextPage = _index + 1;
        if (nextPage >= _deals.length) {
          nextPage = 0;
        }
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _startProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isUserInteracting && mounted) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 0.0;
          }
        });
      }
    });
  }

  void _onUserInteractionStart() {
    setState(() {
      _isUserInteracting = true;
    });
  }

  void _onUserInteractionEnd() {
    setState(() {
      _isUserInteracting = false;
      _progress = 0.0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    _controller.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveHelper.getScreenHeight(context) * 0.24;

    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Carousel takes full width
          GestureDetector(
            onPanStart: (_) {
              HapticFeedback.selectionClick();
              _onUserInteractionStart();
            },
            onPanEnd: (_) => _onUserInteractionEnd(),
            onTapDown: (_) => _onUserInteractionStart(),
            onTapUp: (_) => _onUserInteractionEnd(),
            onTapCancel: () => _onUserInteractionEnd(),
            child: SizedBox(
              height: height,
              child: PageView.builder(
                controller: _controller,
                itemCount: _deals.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _index = i;
                    _progress = 0.0;
                  });
                },
                itemBuilder: (context, i) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_controller.position.haveDimensions) {
                        value = _controller.page! - i;
                        value = (1 - (value.abs() * 0.35)).clamp(0.65, 1.0);
                      }

                      // 3D rotation effect
                      double rotateY = 0.0;
                      if (_controller.position.haveDimensions) {
                        rotateY = (_controller.page! - i) * 0.3;
                      }

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(rotateY)
                          ..scale(value),
                        child: child,
                      );
                    },
                    child: _buildCarouselItem(context, i, height),
                  );
                },
              ),
            ),
          ),

          // Horizontal dots at the bottom
          const SizedBox(height: 12),
          _buildHorizontalIndicators(),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, int index, double height) {
    final deal = _deals[index];
    final isActive = index == _index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isActive ? 20 : 10,
              offset: Offset(0, isActive ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with Parallax
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double parallax = 0.0;
                  if (_controller.position.haveDimensions) {
                    parallax = (_controller.page! - index) * 60;
                  }
                  return Transform.translate(
                    offset: Offset(parallax, 0),
                    child: child,
                  );
                },
                child: Image.asset(deal.image, fit: BoxFit.cover),
              ),

              // Shimmer Effect (only on active card)
              if (isActive)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Subtle gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Badge
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: deal.gradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deal.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Minimalistic Content
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      deal.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      deal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 15,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Pause Indicator
              if (_isUserInteracting)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_deals.length, (i) {
        final selected = i == _index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _onUserInteractionStart();
            _controller.animateToPage(
              i,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              _onUserInteractionEnd();
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: selected ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: selected ? AppColors.primary : Colors.grey.shade300,
              ),
              child: selected
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          // Progress fill (horizontal)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 50),
                              width: 32 * _progress,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

class DealData {
  final String image;
  final String title;
  final String subtitle;
  final String badge;
  final Gradient gradient;

  const DealData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.gradient,
  });
}
