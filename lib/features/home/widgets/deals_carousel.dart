import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../cubits/carousel_cubit.dart';
import '../cubits/carousel_state.dart';

class DealsCarousel extends StatefulWidget {
  const DealsCarousel({super.key});

  @override
  State<DealsCarousel> createState() => _DealsCarouselState();
}

class _DealsCarouselState extends State<DealsCarousel>
    with TickerProviderStateMixin {
  final PageController _controller = PageController(viewportFraction: 0.88);
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onUserInteractionStart() {
    context.read<CarouselCubit>().setUserInteracting(true);
  }

  void _onUserInteractionEnd() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CarouselCubit>().setUserInteracting(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveHelper.getCarouselHeight(context);

    return BlocBuilder<CarouselCubit, CarouselState>(
      // Only rebuild when necessary properties change
      buildWhen: (previous, current) {
        if (previous is! CarouselLoaded || current is! CarouselLoaded) {
          return true;
        }
        return previous.currentIndex != current.currentIndex ||
            previous.isUserInteracting != current.isUserInteracting ||
            previous.progress != current.progress;
      },
      builder: (context, state) {
        if (state is! CarouselLoaded) {
          return SizedBox(height: height);
        }

        // Sync PageController with Cubit state
        if (_controller.hasClients &&
            _controller.page?.round() != state.currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.hasClients) {
              _controller.jumpToPage(state.currentIndex);
            }
          });
        }

        return FadeTransition(
          opacity: _fadeController,
          child: Column(
            children: [
              // Carousel
              GestureDetector(
                onPanStart: (_) => _onUserInteractionStart(),
                onPanEnd: (_) => _onUserInteractionEnd(),
                child: SizedBox(
                  height: height,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: state.deals.length,
                    onPageChanged: (index) {
                      context.read<CarouselCubit>().onPageChanged(index);
                    },
                    itemBuilder: (context, index) {
                      return _CarouselItem(
                        deal: state.deals[index],
                        isActive: index == state.currentIndex,
                        isUserInteracting: state.isUserInteracting,
                        shimmerController: _shimmerController,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal Indicators
              _CarouselIndicators(
                itemCount: state.deals.length,
                currentIndex: state.currentIndex,
                progress: state.progress,
                controller: _controller,
                onIndicatorTap: (index) {
                  HapticFeedback.selectionClick();
                  _onUserInteractionStart();
                  _controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                  context.read<CarouselCubit>().goToPage(index);
                  _onUserInteractionEnd();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual carousel item - Extracted for optimization
class _CarouselItem extends StatelessWidget {
  final DealData deal;
  final bool isActive;
  final bool isUserInteracting;
  final AnimationController shimmerController;

  const _CarouselItem({
    required this.deal,
    required this.isActive,
    required this.isUserInteracting,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(deal.image, fit: BoxFit.cover),

              // Shimmer Effect (only on active)
              if (isActive)
                AnimatedBuilder(
                  animation: shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(
                              alpha: 0.1 * shimmerController.value,
                            ),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),

              // Subtle Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    deal.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Pause Indicator
              if (isUserInteracting)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carousel indicators - Extracted for optimization
class _CarouselIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final double progress;
  final PageController controller;
  final Function(int) onIndicatorTap;

  const _CarouselIndicators({
    required this.itemCount,
    required this.currentIndex,
    required this.progress,
    required this.controller,
    required this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (i) {
        final selected = i == currentIndex;
        return GestureDetector(
          onTap: () => onIndicatorTap(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: selected ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: selected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              child: selected
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          // Progress fill
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 50),
                              width: 32 * progress,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.5),
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
