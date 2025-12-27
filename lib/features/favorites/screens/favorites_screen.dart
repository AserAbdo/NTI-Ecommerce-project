import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../products/models/product_model.dart';
import '../../products/widgets/product_card.dart';
import '../../products/screens/product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.favorites),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('Please login to view favorites')),
      );
    }

    final userId = authState.user.id;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppStrings.favorites,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading favorites',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              title: 'No Favorites Yet',
              message: 'Start adding products to your favorites',
              icon: Icons.favorite_border,
              action: null,
            );
          }

          final favoriteProductIds = snapshot.data!.docs
              .map(
                (doc) =>
                    (doc.data() as Map<String, dynamic>)['productId']
                        as String?,
              )
              .whereType<String>()
              .toList();

          if (favoriteProductIds.isEmpty) {
            return EmptyStateWidget(
              title: 'No Favorites Yet',
              message: 'Start adding products to your favorites',
              icon: Icons.favorite_border,
              action: null,
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: favoriteProductIds)
                .snapshots(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
              }

              if (productSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading products: ${productSnapshot.error}',
                  ),
                );
              }

              if (!productSnapshot.hasData ||
                  productSnapshot.data!.docs.isEmpty) {
                return EmptyStateWidget(
                  title: 'No Products Found',
                  message: 'The favorited products are no longer available',
                  icon: Icons.inventory_2_outlined,
                  action: null,
                );
              }

              final products = productSnapshot.data!.docs
                  .map((doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return ProductModel.fromJson(data);
                    } catch (e) {
                      return null;
                    }
                  })
                  .whereType<ProductModel>()
                  .toList();

              return Column(
                children: [
                  // Header with count
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${products.length} ${products.length == 1 ? 'item' : 'items'} saved',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  // Products Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getHorizontalPadding(
                          context,
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridColumns(
                          context,
                        ),
                        crossAxisSpacing: ResponsiveHelper.getGridSpacing(
                          context,
                        ),
                        mainAxisSpacing: ResponsiveHelper.getGridSpacing(
                          context,
                        ),
                        childAspectRatio:
                            ResponsiveHelper.getProductCardAspectRatio(context),
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
