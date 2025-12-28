import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main/controllers/scroll_visibility_controller.dart';
import '../cubits/products_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_error_state.dart';
import '../widgets/home_loaded_content.dart';
import '../widgets/products_loading_grid.dart';

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
              return HomeErrorState(
                message: state.message,
                onRetry: _onRefresh,
              );
            }
            if (state is ProductsLoaded) {
              return HomeLoadedContent(
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
