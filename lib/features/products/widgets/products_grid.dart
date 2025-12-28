import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/product_model.dart';
import 'product_card.dart';

/// Grid view of products
class ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ScrollController? scrollController;

  const ProductsGrid({
    super.key,
    required this.products,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isSmallMobile(context) ? 2 : 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
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
  }
}
