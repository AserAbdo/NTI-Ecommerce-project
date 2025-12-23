import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../services/seed_service.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../home/cubits/carousel_cubit.dart';
import '../../home/widgets/deals_carousel.dart';
import '../../search/cubits/search_cubit.dart';
import '../../search/screens/search_page.dart';
import '../cubits/products_cubit.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _visibleCount = 10;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home',
    'Beauty',
    'Grocery',
  ];

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProducts();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (!mounted) return;

    final currentState = context.read<ProductsCubit>().state;
    if (currentState is ProductsLoaded) {
      final allProducts = currentState.products;
      if (_visibleCount < allProducts.length && !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _visibleCount += 10;
              if (_visibleCount > allProducts.length) {
                _visibleCount = allProducts.length;
              }
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _visibleCount = 10;
      _isLoadingMore = false;
    });
    context.read<ProductsCubit>().fetchProductsByCategory(category);
  }

  Future<void> _onRefresh() async {
    await context.read<ProductsCubit>().fetchProducts();
    setState(() {
      _visibleCount = 10;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Minimal Greeting
            SliverToBoxAdapter(child: _buildGreetingSection(context)),

            // Deals Carousel
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, title: 'Special Deals'),
                  BlocProvider(
                    create: (_) => CarouselCubit(),
                    child: const DealsCarousel(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, title: 'Categories'),
                  const SizedBox(height: 16),
                  _buildCategoriesSection(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Products Grid
            BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, productsState) {
                if (productsState is ProductsLoading) {
                  return _buildShimmerGrid(context);
                }
                if (productsState is ProductsError) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      message:
                          productsState.message ?? 'Error loading products',
                      icon: Icons.error_outline,
                      buttonText: 'Retry',
                      onButtonPressed: () {
                        context.read<ProductsCubit>().fetchProductsByCategory(
                          _selectedCategory,
                        );
                      },
                    ),
                  );
                }
                if (productsState is ProductsLoaded) {
                  final allProducts = productsState.products;
                  if (allProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        message: 'No products found',
                        icon: Icons.shopping_bag_outlined,
                        buttonText: 'Seed Products',
                        onButtonPressed: () async {
                          await SeedService.seedProducts();
                          if (context.mounted) {
                            context.read<ProductsCubit>().fetchProducts();
                          }
                        },
                      ),
                    );
                  }

                  final displayed = allProducts.take(_visibleCount).toList();

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getHorizontalPadding(
                        context,
                      ),
                      vertical: 0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridColumns(
                          context,
                        ),
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = displayed[index];
                          return ProductCard(
                            key: ValueKey(product.id),
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
                        childCount: displayed.length,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: true,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),

            // Loading More Indicator
            BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, productsState) {
                if (productsState is ProductsLoaded) {
                  final allProducts = productsState.products;
                  final hasMore = _visibleCount < allProducts.length;

                  if (hasMore && _isLoadingMore) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getHorizontalPadding(
                          context,
                        ),
                        vertical: 0,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.getGridColumns(
                            context,
                          ),
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ProductCardShimmer(),
                          childCount: 2,
                        ),
                      ),
                    );
                  }
                }
                return const SliverToBoxAdapter(child: SizedBox(height: 100));
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 70,
      surfaceTintColor: Colors.white,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => SearchCubit(),
                child: const SearchPage(),
              ),
            ),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search on Vendora...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          ResponsiveHelper.getHorizontalPadding(context),
          24,
          ResponsiveHelper.getHorizontalPadding(context),
          32,
        ),
        child: Builder(
          builder: (context) {
            final authState = context.watch<AuthCubit>().state;
            final String userName = authState is AuthAuthenticated
                ? authState.user.name
                : 'Guest';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context) + 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover amazing products',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getBodyFontSize(context) + 4,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context),
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onCategorySelected(cat),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
        vertical: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getGridColumns(context),
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ProductCardShimmer(),
          childCount: 6,
        ),
      ),
    );
  }
}

// Minimalist Shimmer Loading Widget
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      period: const Duration(milliseconds: 1500),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
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
}
