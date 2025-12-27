import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../favorites/cubits/favorites_cubit.dart';
import '../../../services/hive_service.dart';
import '../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Track this product as recently viewed
    HiveService.saveRecentProduct(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Minimalistic App Bar
          _buildAppBar(context),

          // Product Image
          SliverToBoxAdapter(child: _buildProductImage()),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveHelper.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Category & Favorite
                  _buildCategoryAndFavorite(),

                  const SizedBox(height: 16),

                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context) + 8,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rating & Reviews
                  _buildRatingSection(),

                  const SizedBox(height: 20),

                  // Price & Stock
                  _buildPriceAndStock(),

                  const SizedBox(height: 32),

                  // Description
                  _buildDescription(),

                  const SizedBox(height: 32),

                  // Reviews Section
                  _buildReviewsSection(),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Add to Cart Button
      bottomNavigationBar: _buildBottomBar(userId),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor:
          Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 20),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product-${widget.product.id}',
      child: Container(
        width: double.infinity,
        height: ResponsiveHelper.getScreenHeight(context) * 0.4,
        color: Theme.of(context).cardColor,
        child: CachedNetworkImage(
          imageUrl: widget.product.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryAndFavorite() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.product.category,
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ??
                  AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Favorite Button
        BlocBuilder<FavoritesCubit, Set<String>>(
          builder: (context, favs) {
            final isFav = favs.contains(widget.product.id);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Please login to favorite products',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }

                  final favoritesCubit = context.read<FavoritesCubit>();
                  await favoritesCubit.toggleFavorite(widget.product);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFav
                        ? Colors.red.shade50
                        : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    if (widget.product.reviewsCount == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 6),
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${widget.product.reviewsCount} reviews)',
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndStock() {
    final hasDiscount =
        widget.product.oldPrice != null &&
        widget.product.oldPrice! >
            (widget.product.newPrice ?? widget.product.price);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.product.newPrice ?? widget.product.price)
                      .toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context) + 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AppStrings.egp,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),

            // Old Price
            if (hasDiscount)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(
                      '${widget.product.oldPrice!.toStringAsFixed(0)} ${AppStrings.egp}',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${(((widget.product.oldPrice! - (widget.product.newPrice ?? widget.product.price)) / widget.product.oldPrice!) * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Stock Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.product.stock > 0
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.product.stock > 0 ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: widget.product.stock > 0
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                widget.product.stock > 0
                    ? AppStrings.inStock
                    : AppStrings.outOfStock,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                  color: widget.product.stock > 0
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context) + 4,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context) + 4,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            if (widget.product.reviewsCount > 0)
              Text(
                '${widget.product.reviewsCount} total',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Reviews List
        if (widget.product.reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...widget.product.reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(review) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info & Rating
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context) - 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Stars
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context),
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildBottomBar(String? userId) {
    if (widget.product.stock == 0 || userId == null) {
      return null;
    }

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              await context.read<CartCubit>().addToCart(userId, widget.product);
              if (context.mounted) {
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
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 22),
                const SizedBox(width: 12),
                Text(
                  AppStrings.addToCart,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
