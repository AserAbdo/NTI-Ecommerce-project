import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/firebase_service.dart';
import '../../../services/hive_service.dart';
import '../../products/models/product_model.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  List<ProductModel> _allProducts = [];
  Timer? _debounceTimer;
  List<String> _searchHistory = [];
  static const int maxHistoryItems = 10;

  /// Load recent products from Hive
  Future<void> loadRecentProducts() async {
    try {
      emit(SearchLoading());

      final recentIds = await HiveService.getRecentProducts();
      _searchHistory = await HiveService.getSearchHistory();

      if (recentIds.isEmpty) {
        emit(
          RecentProductsLoaded(
            recentProducts: [],
            searchHistory: _searchHistory,
            popularSearches: _getPopularSearches(),
          ),
        );
        return;
      }

      // Fetch all products if not already loaded
      if (_allProducts.isEmpty) {
        await _fetchAllProducts();
      }

      final recentProducts = _allProducts
          .where((product) => recentIds.contains(product.id))
          .toList();

      emit(
        RecentProductsLoaded(
          recentProducts: recentProducts,
          searchHistory: _searchHistory,
          popularSearches: _getPopularSearches(),
        ),
      );
    } catch (e) {
      emit(SearchError('Failed to load recent products: $e'));
    }
  }

  /// Get popular/trending searches
  List<String> _getPopularSearches() {
    return [
      'iPhone',
      'Laptop',
      'Headphones',
      'Watch',
      'Shoes',
      'T-Shirt',
      'Coffee',
      'Skincare',
    ];
  }

  /// Fetch all products from Firebase
  Future<void> _fetchAllProducts() async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('products')
          .get();
      _allProducts = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Search products by query with debounce
  void searchProducts(String query) {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      loadRecentProducts();
      return;
    }

    // Show suggestions immediately
    if (_allProducts.isNotEmpty) {
      final suggestions = _getSuggestions(trimmedQuery);
      emit(SearchSuggestions(suggestions: suggestions, query: trimmedQuery));
    }

    // Debounce actual search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(trimmedQuery);
    });
  }

  /// Get search suggestions
  List<String> _getSuggestions(String query) {
    final queryLower = query.toLowerCase();
    final suggestions = <String>{};

    // Add from product names
    for (final product in _allProducts) {
      if (product.name.toLowerCase().contains(queryLower)) {
        suggestions.add(product.name);
      }
      if (product.category.toLowerCase().contains(queryLower)) {
        suggestions.add(product.category);
      }
    }

    // Add from search history
    for (final item in _searchHistory) {
      if (item.toLowerCase().contains(queryLower)) {
        suggestions.add(item);
      }
    }

    return suggestions.take(8).toList();
  }

  /// Perform actual search
  Future<void> _performSearch(String query) async {
    try {
      emit(SearchLoading());

      // Fetch all products if not already loaded
      if (_allProducts.isEmpty) {
        await _fetchAllProducts();
      }

      // Save to search history
      await _saveToHistory(query);

      // Search in name, description, and category with relevance scoring
      final results = _allProducts.where((product) {
        final nameLower = product.name.toLowerCase();
        final descLower = product.description.toLowerCase();
        final categoryLower = product.category.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) ||
            descLower.contains(queryLower) ||
            categoryLower.contains(queryLower);
      }).toList();

      // Sort by relevance (name matches first)
      results.sort((a, b) {
        final aNameMatch = a.name.toLowerCase().contains(query.toLowerCase());
        final bNameMatch = b.name.toLowerCase().contains(query.toLowerCase());

        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;

        // Then by rating
        return b.rating.compareTo(a.rating);
      });

      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError('Search failed: $e'));
    }
  }

  /// Save search query to history
  Future<void> _saveToHistory(String query) async {
    if (query.length < 2) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    if (_searchHistory.length > maxHistoryItems) {
      _searchHistory = _searchHistory.take(maxHistoryItems).toList();
    }

    await HiveService.saveSearchHistory(_searchHistory);
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await HiveService.saveSearchHistory([]);
    loadRecentProducts();
  }

  /// Remove single item from history
  Future<void> removeFromHistory(String query) async {
    _searchHistory.remove(query);
    await HiveService.saveSearchHistory(_searchHistory);
    loadRecentProducts();
  }

  /// Clear search and return to recent products
  void clearSearch() {
    _debounceTimer?.cancel();
    loadRecentProducts();
  }

  /// Filter by category
  void filterByCategory(String category) {
    if (_allProducts.isEmpty) return;

    final results = _allProducts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();

    emit(SearchLoaded(results: results, query: category));
  }

  /// Filter by price range
  void filterByPriceRange(double minPrice, double maxPrice) {
    final currentState = state;
    List<ProductModel> products = [];

    if (currentState is SearchLoaded) {
      products = currentState.results.cast<ProductModel>();
    } else {
      products = _allProducts;
    }

    final filtered = products
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();

    emit(
      SearchLoaded(
        results: filtered,
        query: currentState is SearchLoaded ? currentState.query : 'Filtered',
      ),
    );
  }

  /// Sort results
  void sortResults(SortOption option) {
    final currentState = state;
    if (currentState is! SearchLoaded) return;

    final results = List<ProductModel>.from(
      currentState.results.cast<ProductModel>(),
    );

    switch (option) {
      case SortOption.priceLowToHigh:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.newest:
        // Assuming products are already sorted by newest
        break;
    }

    emit(SearchLoaded(results: results, query: currentState.query));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

enum SortOption { priceLowToHigh, priceHighToLow, rating, newest }
