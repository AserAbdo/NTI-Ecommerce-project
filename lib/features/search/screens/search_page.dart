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

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Load recent products when page opens
    context.read<SearchCubit>().loadRecentProducts();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
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

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    context.read<SearchCubit>().searchProducts(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return _buildLoadingState(isDark);
            }

            if (state is SearchError) {
              return _buildErrorState(state.message, isDark);
            }

            if (state is SearchSuggestions) {
              return _buildSuggestions(state.suggestions, state.query, isDark);
            }

            if (state is RecentProductsLoaded) {
              return _buildRecentAndPopular(state, isDark);
            }

            if (state is SearchLoaded) {
              return _buildSearchResults(state.results, state.query, isDark);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search products, brands, categories...',
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.grey.shade500
                  : AppColors.textSecondary.withOpacity(0.5),
              fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey.shade400 : AppColors.primary,
              size: 22,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : AppColors.textSecondary,
                        size: 16,
                      ),
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
              vertical: 14,
            ),
          ),
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    List<String> suggestions,
    String query,
    bool isDark,
  ) {
    if (suggestions.isEmpty) {
      return _buildNoSuggestions(isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              size: 18,
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            ),
          ),
          title: _highlightMatch(suggestion, query, isDark),
          trailing: Icon(
            Icons.north_west,
            size: 16,
            color: isDark ? Colors.grey.shade500 : AppColors.textSecondary,
          ),
          onTap: () => _selectSuggestion(suggestion),
        );
      },
    );
  }

  Widget _highlightMatch(String text, String query, bool isDark) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex < 0) {
      return Text(
        text,
        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 15,
        ),
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }

  Widget _buildNoSuggestions(bool isDark) {
    return Center(
      child: Text(
        'No suggestions found',
        style: TextStyle(
          color: isDark ? Colors.grey.shade500 : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRecentAndPopular(RecentProductsLoaded state, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          if (state.searchHistory.isNotEmpty) ...[
            _buildSectionHeader(
              'Recent Searches',
              Icons.history,
              isDark,
              onClear: () => context.read<SearchCubit>().clearSearchHistory(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.searchHistory.map((query) {
                return _buildHistoryChip(query, isDark);
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          _buildSectionHeader('Popular Searches', Icons.trending_up, isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.popularSearches.map((query) {
              return _buildPopularChip(query, isDark);
            }).toList(),
          ),

          // Recently Viewed Products
          if (state.recentProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Recently Viewed', Icons.visibility, isDark),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.getGridColumns(context),
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.recentProducts.length,
              itemBuilder: (context, index) {
                final product = state.recentProducts[index];
                return ProductCard(
                  product: product,
                  heroTagSuffix: 'recent',
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
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    bool isDark, {
    VoidCallback? onClear,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryChip(String query, bool isDark) {
    return InkWell(
      onTap: () => _selectSuggestion(query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 14,
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              query,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.read<SearchCubit>().removeFromHistory(query),
              child: Icon(
                Icons.close,
                size: 14,
                color: isDark ? Colors.grey.shade500 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularChip(String query, bool isDark) {
    return InkWell(
      onTap: () => _selectSuggestion(query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            const SizedBox(width: 6),
            Text(
              query,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results, String query, bool isDark) {
    return Column(
      children: [
        // Results header with sort/filter
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getHorizontalPadding(context),
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.search, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${results.length} ',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(
                        text: results.length == 1 ? 'result' : 'results',
                      ),
                      const TextSpan(text: ' for '),
                      TextSpan(
                        text: '"$query"',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              _buildSortButton(isDark),
            ],
          ),
        ),

        // Results grid
        Expanded(
          child: results.isEmpty
              ? _buildNoResults(isDark)
              : GridView.builder(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getHorizontalPadding(context),
                  ),
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
                      heroTagSuffix: 'search',
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
    );
  }

  Widget _buildSortButton(bool isDark) {
    return PopupMenuButton<SortOption>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.sort,
          size: 18,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      onSelected: (option) {
        context.read<SearchCubit>().sortResults(option);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SortOption.rating,
          child: Row(
            children: [
              Icon(Icons.star, size: 18),
              SizedBox(width: 8),
              Text('Top Rated'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortOption.priceLowToHigh,
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 18),
              SizedBox(width: 8),
              Text('Price: Low to High'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortOption.priceHighToLow,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 18),
              SizedBox(width: 8),
              Text('Price: High to Low'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SortOption.newest,
          child: Row(
            children: [
              Icon(Icons.new_releases, size: 18),
              SizedBox(width: 8),
              Text('Newest'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800
                  : AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark
                  ? Colors.grey.shade600
                  : AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or check spelling',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
