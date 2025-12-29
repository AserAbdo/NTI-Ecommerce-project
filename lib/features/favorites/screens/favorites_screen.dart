import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../favorites/cubits/favorites_cubit.dart';
import '../../products/widgets/product_card.dart';
import '../../products/models/product_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.myFavorites,
            style: TextStyle(
              fontSize: ResponsiveHelper.getSubtitleFontSize(context),
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('Please login to see favorites')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.myFavorites,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: context.read<FavoritesCubit>().favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const EmptyStateWidget(
              message: AppStrings.noFavorites,
              icon: Icons.favorite_border,
              buttonText: 'Start Shopping',
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(
              ResponsiveHelper.getHorizontalPadding(context) * 0.66,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.getGridColumns(context),
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                heroTagSuffix: 'favorites',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.productDetails,
                    arguments: product,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
