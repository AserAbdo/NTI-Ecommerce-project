import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../home/widgets/deals_carousel.dart';
import '../../main/controllers/scroll_visibility_controller.dart';
import '../cubits/products_cubit.dart';
import '../widgets/categories_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/products_loading_grid.dart';
import '../widgets/section_header.dart';

/// Home screen displaying products, categories, and deals
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollVisibilityController _navbarController =
      ScrollVisibilityController();
  String _selectedCategory = 'All';
  bool _isLoadingMore = false;

  // Keep this screen alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Only load products if not already loaded
    final state = context.read<ProductsCubit>().state;
    if (state is! ProductsLoaded) {
      context.read<ProductsCubit>().loadProducts();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Update navbar visibility based on scroll direction
    _navbarController.onScroll(_scrollController.offset);

    // Load more products when reaching end
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && !_isLoadingMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() => _isLoadingMore = true);
    final state = context.read<ProductsCubit>().state;
    if (state is ProductsLoaded && state.hasMore) {
      await context.read<ProductsCubit>().loadMoreProducts();
    }
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() => _selectedCategory = category);
      context.read<ProductsCubit>().filterByCategory(
        category == 'All' ? null : category,
      );
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ProductsCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        // Use BlocBuilder with buildWhen for optimization
        child: BlocBuilder<ProductsCubit, ProductsState>(
          buildWhen: (previous, current) {
            // Only rebuild when state type changes or products change
            if (previous.runtimeType != current.runtimeType) return true;
            if (previous is ProductsLoaded && current is ProductsLoaded) {
              return previous.products.length != current.products.length ||
                  previous.hasMore != current.hasMore;
            }
            return true;
          },
          builder: (context, state) {
            if (state is ProductsLoading && _selectedCategory == 'All') {
              return const HomeLoadingShimmer();
            }
            if (state is ProductsError) {
              return _ErrorState(message: state.message, onRetry: _onRefresh);
            }
            if (state is ProductsLoaded) {
              return _LoadedContent(
                state: state,
                scrollController: _scrollController,
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
                isLoadingMore: _isLoadingMore,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Error state widget - Extracted for cleaner code
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Loaded content - Extracted for optimization
class _LoadedContent extends StatelessWidget {
  final ProductsLoaded state;
  final ScrollController scrollController;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isLoadingMore;

  const _LoadedContent({
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
              // Wrap in RepaintBoundary to prevent carousel from causing full repaints
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
            ? const SliverToBoxAdapter(child: _EmptyState())
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
                      // Wrap each product card in RepaintBoundary for isolation
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
                    // Add more efficient child rebuilding
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: false, // We're adding them manually
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

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different category',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
