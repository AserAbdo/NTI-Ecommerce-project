import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.productDetails,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: ResponsiveHelper.getScreenHeight(context) * 0.4,
              color: Colors.grey,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image, size: 100)),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                ResponsiveHelper.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
                  // Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),
                  // Price + Stock (Updated)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} ${AppStrings.egp}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getSubtitleFontSize(
                            context,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.stock > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.inStock,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getBodyFontSize(
                                    context,
                                  ),
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.outOfStock,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getBodyFontSize(
                                    context,
                                  ),
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                  // Description
                  Text(
                    AppStrings.description,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 8)),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 32)),
                  // Reviews Section
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (product.reviews.isEmpty)
                    Text(
                      'No reviews yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ...product.reviews.map(
                    (review) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(review.userName[0])),
                        title: Text(review.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(review.rating.toString()),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(review.comment),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, 32)),
                  // Add to Cart Button - ONLY IF IN STOCK
                  if (product.stock > 0 && userId != null)
                    CustomButton(
                      text: AppStrings.addToCart,
                      onPressed: () async {
                        await context.read<CartCubit>().addToCart(
                          userId!,
                          product,
                        );
                        if (context.mounted) {
                          context.read<CartCubit>().loadCart(userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
