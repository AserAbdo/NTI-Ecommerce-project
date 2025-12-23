import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../products/widgets/product_card.dart';
import '../cubits/search_cubit.dart';
import '../cubits/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load recent products when page opens
    context.read<SearchCubit>().loadRecentProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<SearchCubit>().searchProducts(value);
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    context.read<SearchCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            onChanged: _onSearchChanged,
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search on Vendora',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _clearSearch();
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is RecentProductsLoaded) {
            return _buildRecentProducts(state.recentProducts);
          }

          if (state is SearchLoaded) {
            return _buildSearchResults(state.results, state.query);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRecentProducts(List<dynamic> recentProducts) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Recently Viewed',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recentProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent products',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Products you view will appear here',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getBodyFontSize(context) - 2,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.getGridColumns(context),
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: recentProducts.length,
                    itemBuilder: (context, index) {
                      final product = recentProducts[index];
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results, String query) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${results.length} ',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(
                        text: results.length == 1 ? 'result' : 'results',
                      ),
                      TextSpan(text: ' for '),
                      TextSpan(
                        text: '"$query"',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getBodyFontSize(context) - 2,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.getGridColumns(context),
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
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
                  ),
          ),
        ],
      ),
    );
  }
}
