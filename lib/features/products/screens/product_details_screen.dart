import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../models/review_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _quantity = 1;
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    HiveService.saveRecentProduct(widget.product.id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    String? userId;
    String? userName;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
      userName = authState.user.name;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image
            _buildProductImage(isDark),

            // Product Details
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildProductDetails(isDark, userId, userName),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(userId, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _buildIconButton(
          Icons.arrow_back,
          () => Navigator.pop(context),
          isDark,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _buildIconButton(Icons.share_rounded, () {}, isDark),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildIconButton(
            Icons.shopping_cart_outlined,
            () => Navigator.pushNamed(context, AppRoutes.cart),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildProductImage(bool isDark) {
    return Hero(
      tag: 'product-${widget.product.id}',
      child: Container(
        width: double.infinity,
        height: ResponsiveHelper.getScreenHeight(context) * 0.35,
        color: isDark ? Colors.black : Colors.white,
        child: Stack(
          children: [
            // Main Image - Centered with contain
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 60,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Discount Badge - Primary Color
            if (widget.product.oldPrice != null &&
                widget.product.oldPrice! > widget.product.price)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
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
                    '-${(((widget.product.oldPrice! - widget.product.price) / widget.product.oldPrice!) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(bool isDark, String? userId, String? userName) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category & Favorite
            _buildCategoryAndFavorite(isDark),

            const SizedBox(height: 16),

            // Product Name
            Text(
              _product.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // Rating
            if (_product.reviewsCount > 0) _buildRatingSection(isDark),

            const SizedBox(height: 20),

            // Price Section
            _buildPriceSection(isDark),

            const SizedBox(height: 24),

            // Quantity Selector
            _buildQuantitySelector(isDark),

            const SizedBox(height: 28),

            // Description
            _buildDescriptionSection(isDark),

            const SizedBox(height: 28),

            // Features
            _buildFeaturesSection(isDark),

            const SizedBox(height: 28),

            // Reviews
            _buildReviewsSection(isDark, userId, userName),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndFavorite(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                _product.category,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        BlocBuilder<FavoritesCubit, Set<String>>(
          builder: (context, favs) {
            final isFav = favs.contains(_product.id);
            return GestureDetector(
              onTap: () async {
                final authState = context.read<AuthCubit>().state;
                if (authState is! AuthAuthenticated) {
                  _showLoginSnackBar();
                  return;
                }
                try {
                  final wasAdded = await context
                      .read<FavoritesCubit>()
                      .toggleFavorite(_product);
                  if (mounted) {
                    _showFavoriteSnackBar(wasAdded, isDark);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update favorites'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFav
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav
                      ? AppColors.primary
                      : (isDark
                            ? Colors.grey.shade400
                            : AppColors.textSecondary),
                  size: 22,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Show professional snackbar when adding/removing from favorites
  void _showFavoriteSnackBar(bool wasAdded, bool isDark) {
    // Clear any existing snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Product Image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: _product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wasAdded ? 'Added to Favorites' : 'Removed from Favorites',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Icon
            Icon(
              wasAdded ? Icons.favorite : Icons.favorite_border,
              color: wasAdded ? Colors.redAccent : Colors.white70,
              size: 24,
            ),
          ],
        ),
        backgroundColor: wasAdded
            ? AppColors.primary
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  Widget _buildRatingSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            final rating = _product.rating;
            if (index < rating.floor()) {
              return const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 18,
              );
            } else if (index < rating) {
              return const Icon(
                Icons.star_half_rounded,
                color: Colors.amber,
                size: 18,
              );
            }
            return Icon(
              Icons.star_outline_rounded,
              color: Colors.amber.shade200,
              size: 18,
            );
          }),
          const SizedBox(width: 8),
          Text(
            _product.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${_product.reviewsCount})',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    final hasDiscount =
        _product.oldPrice != null && _product.oldPrice! > _product.price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade800, Colors.grey.shade900]
              : [Colors.grey.shade50, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDiscount)
                Text(
                  '${_product.oldPrice!.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey.shade500
                        : AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _product.price.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      AppStrings.egp,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _product.stock > 0
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _product.stock > 0 ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: _product.stock > 0
                      ? AppColors.success
                      : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  _product.stock > 0 ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _product.stock > 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildQuantityButton(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }, isDark),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildQuantityButton(Icons.add, () {
                  if (_quantity < _product.stock) setState(() => _quantity++);
                }, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description', Icons.description_outlined, isDark),
        const SizedBox(height: 12),
        Text(
          _product.description,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final features = [
      {'icon': Icons.local_shipping_outlined, 'text': 'Free Delivery'},
      {'icon': Icons.verified_outlined, 'text': 'Genuine Product'},
      {'icon': Icons.replay_outlined, 'text': '7 Days Return'},
      {'icon': Icons.support_agent_outlined, 'text': '24/7 Support'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Why Buy From Us', Icons.star_outline, isDark),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: features.map((f) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      f['text'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(bool isDark, String? userId, String? userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Reviews', Icons.rate_review_outlined, isDark),
            if (_product.reviewsCount > 0)
              Text(
                '${_product.reviewsCount} reviews',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.grey.shade500
                      : AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Add Review Button
        if (userId != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showAddReviewDialog(isDark, userId, userName ?? 'User'),
              icon: Icon(Icons.add, color: AppColors.primary),
              label: Text(
                'Write a Review',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (_product.reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade500
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to review this product',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._product.reviews.map((review) => _buildReviewCard(review, isDark)),
      ],
    );
  }

  void _showAddReviewDialog(bool isDark, String userId, String userName) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Write a Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your experience with this product',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey.shade400
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Rating Stars
                Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setModalState(() => selectedRating = index + 1.0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Comment
                Text(
                  'Your Review',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Tell others what you think about this product...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please write a review'),
                          ),
                        );
                        return;
                      }

                      await _submitReview(
                        userId,
                        userName,
                        selectedRating,
                        commentController.text.trim(),
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview(
    String userId,
    String userName,
    double rating,
    String comment,
  ) async {
    try {
      final newReview = {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.now(),
      };

      // Add review to product document
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_product.id)
          .update({
            'reviews': FieldValue.arrayUnion([newReview]),
            'reviewsCount': FieldValue.increment(1),
          });

      // Calculate new average rating
      final allRatings = _product.reviews.map((r) => r.rating).toList();
      allRatings.add(rating);
      final newAvgRating =
          allRatings.reduce((a, b) => a + b) / allRatings.length;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(_product.id)
          .update({'rating': newAvgRating});

      // Update local state
      if (mounted) {
        setState(() {
          _product = _product.copyWith(
            reviews: [
              ..._product.reviews,
              ReviewModel(
                userId: userId,
                userName: userName,
                rating: rating,
                comment: comment,
                createdAt: DateTime.now(),
              ),
            ],
            reviewsCount: _product.reviewsCount + 1,
            rating: newAvgRating,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Review submitted successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildReviewCard(ReviewModel review, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(String? userId, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(_product.price * _quantity).toStringAsFixed(0)} ${AppStrings.egp}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _product.stock == 0 || userId == null
                    ? (userId == null ? () => _showLoginSnackBar() : null)
                    : () => _addToCart(userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _product.stock == 0
                      ? Colors.grey
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _product.stock == 0
                          ? Icons.remove_shopping_cart
                          : Icons.shopping_cart_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _product.stock == 0
                          ? 'Out of Stock'
                          : (userId == null ? 'Login to Buy' : 'Add to Cart'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please login to continue'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
      ),
    );
  }

  Future<void> _addToCart(String userId) async {
    await context.read<CartCubit>().addToCart(
      userId,
      _product,
      quantity: _quantity,
    );

    if (mounted) {
      context.read<CartCubit>().loadCart(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_quantity x ${_product.name} added',
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
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ),
      );
    }
  }
}
