import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../home/widgets/deals_carousel.dart';
import '../cubits/products_cubit.dart';
import '../widgets/categories_section.dart';
import '../widgets/greeting_section.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().loadProducts();
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
    setState(() => _selectedCategory = category);
    context.read<ProductsCubit>().filterByCategory(
      category == 'All' ? null : category,
    );
  }

  Future<void> _onRefresh() async {
    await context.read<ProductsCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading && _selectedCategory == 'All') {
              return _buildLoadingState();
            }
            if (state is ProductsError) {
              return _buildErrorState(state.message);
            }
            if (state is ProductsLoaded) {
              return _buildLoadedState(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const HomeLoadingShimmer();
  }

  Widget _buildErrorState(String message) {
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
            ElevatedButton(onPressed: _onRefresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(ProductsLoaded state) {
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
      controller: _scrollController,
      slivers: [
        // Greeting Section
        const SliverToBoxAdapter(child: GreetingSection()),

        SliverToBoxAdapter(
          child: SizedBox(
            height: ResponsiveHelper.isSmallMobile(context) ? 16 : 24,
          ),
        ),

        // Special Deals Section
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SectionHeader(title: 'Special Deals'),
              SizedBox(
                height: ResponsiveHelper.isSmallMobile(context) ? 12 : 16,
              ),
              const DealsCarousel(),
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
          child: CategoriesSection(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
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

        // Products Grid - Responsive columns
        state.products.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState())
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = state.products[index];
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
                  }, childCount: state.products.length),
                ),
              ),

        // Loading More Indicator
        if (_isLoadingMore && state.hasMore)
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

  Widget _buildEmptyState() {
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
