import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../services/seed_service.dart';
import '../../../services/hive_service.dart';
import '../cubits/products_cubit.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProducts();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await HiveService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      context.read<ProductsCubit>().fetchProducts();
      return;
    }
    await HiveService.saveSearchQuery(query);
    await _loadSearchHistory();
    // TODO: Implement actual search in ProductsCubit
    context.read<ProductsCubit>().searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Colors.white.withAlpha((0.7 * 255).toInt()),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
                  setState(() {
                    _isSearching = false;
                  });
                },
              )
            : Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                _performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Recent Searches Dropdown (when searching)
          if (_isSearching && _searchHistory.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  final query = _searchHistory[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(query),
                    onTap: () {
                      _searchController.text = query;
                      _performSearch(query);
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  );
                },
              ),
            ),
          // Products Grid (NO WELCOME BANNER)
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, productsState) {
                if (productsState is ProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (productsState is ProductsError) {
                  return EmptyStateWidget(
                    message: productsState.message ?? 'Error',
                    icon: Icons.error_outline,
                    buttonText: 'Retry',
                    onButtonPressed: () {
                      context.read<ProductsCubit>().fetchProducts();
                    },
                  );
                }
                if (productsState is ProductsLoaded) {
                  if (productsState.products.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No products found',
                      icon: Icons.shopping_bag_outlined,
                      buttonText: 'Seed Products',
                      onButtonPressed: () async {
                        await SeedService.seedProducts();
                        if (context.mounted) {
                          context.read<ProductsCubit>().fetchProducts();
                        }
                      },
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
                    itemCount: productsState.products.length,
                    itemBuilder: (context, index) {
                      final product = productsState.products[index];
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
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
