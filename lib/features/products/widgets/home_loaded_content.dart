import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../home/widgets/deals_carousel.dart';
import '../cubits/products_cubit.dart';
import 'categories_section.dart';
import 'home_empty_state.dart';
import 'product_card.dart';
import 'section_header.dart';

/// Content widget displayed when products are loaded
class HomeLoadedContent extends StatelessWidget {
  final ProductsLoaded state;
  final ScrollController scrollController;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isLoadingMore;

  const HomeLoadedContent({
    super.key,
    required this.state,
    required this.scrollController,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    // Responsive grid columns
    int crossAxisCount = 2;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    }

    // Responsive aspect ratio
    double childAspectRatio = 0.7;
    if (isDesktop) {
      childAspectRatio = 0.75;
    } else if (isTablet) {
      childAspectRatio = 0.72;
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Top spacing
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Special Deals Section
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SectionHeader(title: 'Special Deals'),
              SizedBox(
                height: ResponsiveHelper.isSmallMobile(context) ? 12 : 16,
              ),
              const RepaintBoundary(child: DealsCarousel()),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: ResponsiveHelper.isSmallMobile(context) ? 20 : 28,
          ),
        ),

        // Categories Section
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: CategoriesSection(
              selectedCategory: selectedCategory,
              onCategorySelected: onCategorySelected,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: ResponsiveHelper.isSmallMobile(context) ? 20 : 28,
          ),
        ),

        // All Products Section
        const SliverToBoxAdapter(child: SectionHeader(title: 'All Products')),

        SliverToBoxAdapter(
          child: SizedBox(
            height: ResponsiveHelper.isSmallMobile(context) ? 12 : 16,
          ),
        ),

        // Products Grid
        state.products.isEmpty
            ? const SliverToBoxAdapter(child: HomeEmptyState())
            : SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: isTablet ? 16 : 12,
                    mainAxisSpacing: isTablet ? 16 : 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.products[index];
                      return RepaintBoundary(
                        child: ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: product,
                            );
                          },
                        ),
                      );
                    },
                    childCount: state.products.length,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: false,
                  ),
                ),
              ),

        // Loading More Indicator
        if (isLoadingMore && state.hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // Bottom Spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
