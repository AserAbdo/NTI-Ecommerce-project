import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../cart/cubits/cart_cubit.dart';

import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  // Keep the widget alive to prevent rebuilds during scroll
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _discountPercent() {
    final oldP = widget.product.oldPrice;
    final newP = widget.product.newPrice ?? widget.product.price;
    if (oldP != null && oldP > newP && oldP > 0) {
      return ((oldP - newP) / oldP * 100).round();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Only rebuild when userId changes, not entire auth state
    final userId = context.select<AuthCubit, String?>((cubit) {
      final state = cubit.state;
      return state is AuthAuthenticated ? state.user.id : null;
    });

    final discount = _discountPercent();
    final priceFont = ResponsiveHelper.getBodyFontSize(context) + 2;
    final currencyFont = ResponsiveHelper.getBodyFontSize(context) - 2;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 4 : 6),
                spreadRadius: _isPressed ? 0 : 1,
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SECTION
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      // Main Image with proper error handling
                      Positioned.fill(child: _buildProductImage()),

                      // Discount Badge (bottom-left, enhanced)
                      if (discount != null)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: _buildDiscountBadge(discount),
                        ),

                      // Stock Badge
                      if (widget.product.stock <= 5 && widget.product.stock > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _buildStockBadge(),
                        ),

                      // Out of Stock Overlay
                      if (widget.product.stock == 0)
                        Positioned.fill(child: _buildOutOfStockOverlay()),
                    ],
                  ),
                ),

                // INFO SECTION
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: ResponsiveHelper.getProductCardPadding(context),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // PRODUCT NAME
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                AppColors.textPrimary,
                            height: 1.2,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // RATING DISPLAY
                        _buildRatingDisplay(),

                        const Spacer(),

                        // PRICE ROW + ACTION BUTTON
                        _buildPriceRow(userId, priceFont, currencyFont),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product-${widget.product.id}',
      child: CachedNetworkImage(
        imageUrl: widget.product.imageUrl,
        fit: BoxFit.cover,
        // Error handling with Image.network fallback
        errorWidget: (context, url, error) {
          // Try Image.network as fallback
          return Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.primary.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Final fallback - show error icon
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        // Loading placeholder
        placeholder: (context, url) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        },
        // Faster fade animation for smoother experience
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  Widget _buildDiscountBadge(int discount) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              '-$discount%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            'Only ${widget.product.stock} left',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Text(
            'OUT OF STOCK',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingDisplay() {
    // Only show if there are reviews
    if (widget.product.reviewsCount == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Star icon
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        // Rating value
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context) - 2,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        // Review count
        Text(
          '(${widget.product.reviewsCount})',
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context) - 3,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String? userId, double priceFont, double currencyFont) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Prices
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Old price ABOVE (if exists)
              if (widget.product.oldPrice != null &&
                  widget.product.oldPrice! >
                      (widget.product.newPrice ?? widget.product.price))
                Text(
                  '${widget.product.oldPrice!.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: TextStyle(
                    fontSize: currencyFont - 1,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                  ),
                ),
              // New price BELOW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.product.newPrice ?? widget.product.price)
                        .toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: priceFont,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.egp,
                    style: TextStyle(
                      fontSize: currencyFont,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ADD TO CART BUTTON
        if (widget.product.stock > 0 && userId != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                try {
                  await context.read<CartCubit>().addToCart(
                    userId,
                    widget.product,
                  );
                  if (mounted && context.mounted) {
                    context.read<CartCubit>().loadCart(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${widget.product.name} added to cart',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.primary.withValues(alpha: 0.3),
              child: Container(
                width: ResponsiveHelper.getAddToCartButtonSize(context),
                height: ResponsiveHelper.getAddToCartButtonSize(context),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                  size: ResponsiveHelper.getAddToCartIconSize(context),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
