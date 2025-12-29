import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../cart/cubits/cart_state.dart';

/// Floating cart button with item count badge
class CartFloatingButton extends StatelessWidget {
  final AnimationController animationController;

  /// Whether to animate the button down (when navbar is hidden)
  final bool isNavbarHidden;

  /// The height of the navbar for animation offset
  final double navbarHeight;

  const CartFloatingButton({
    super.key,
    required this.animationController,
    this.isNavbarHidden = false,
    this.navbarHeight = 70,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // Move down when navbar is hidden to take its space
      margin: EdgeInsets.only(bottom: isNavbarHidden ? 0 : 0),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
        child: BlocSelector<CartCubit, CartState, int>(
          selector: (state) {
            if (state is CartLoaded) {
              return state.items.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
            }
            return 0;
          },
          builder: (context, count) {
            return _CartButtonContent(
              count: count,
              animationController: animationController,
            );
          },
        ),
      ),
    );
  }
}

/// Internal cart button content
class _CartButtonContent extends StatelessWidget {
  final int count;
  final AnimationController animationController;

  const _CartButtonContent({
    required this.count,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.isSmallMobile(context) ? 60.0 : 68.0;

    return GestureDetector(
      onTapDown: (_) => animationController.reverse(),
      onTapUp: (_) {
        animationController.forward();
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, AppRoutes.cart);
      },
      onTapCancel: () => animationController.forward(),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: ResponsiveHelper.isSmallMobile(context) ? 26 : 30,
              ),
            ),
            if (count > 0) _CartBadge(count: count),
          ],
        ),
      ),
    );
  }
}

/// Cart badge showing item count
class _CartBadge extends StatelessWidget {
  final int count;

  const _CartBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 2,
      top: 2,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          child: Center(
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
