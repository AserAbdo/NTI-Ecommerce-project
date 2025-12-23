import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/firebase_service.dart';
import '../../../services/hive_service.dart';
import '../../products/models/product_model.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  List<ProductModel> _allProducts = [];

  /// Load recent products from Hive
  Future<void> loadRecentProducts() async {
    try {
      emit(SearchLoading());

      final recentIds = await HiveService.getRecentProducts();

      if (recentIds.isEmpty) {
        emit(const RecentProductsLoaded([]));
        return;
      }

      // Fetch all products if not already loaded
      if (_allProducts.isEmpty) {
        await _fetchAllProducts();
      }

      final recentProducts = _allProducts
          .where((product) => recentIds.contains(product.id))
          .toList();

      emit(RecentProductsLoaded(recentProducts));
    } catch (e) {
      emit(SearchError('Failed to load recent products: $e'));
    }
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

  /// Search products by query
  Future<void> searchProducts(String query) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        // If query is empty, load recent products
        await loadRecentProducts();
        return;
      }

      emit(SearchLoading());

      // Fetch all products if not already loaded
      if (_allProducts.isEmpty) {
        await _fetchAllProducts();
      }

      // Search in name, description, and category
      final results = _allProducts.where((product) {
        final nameLower = product.name.toLowerCase();
        final descLower = product.description.toLowerCase();
        final categoryLower = product.category.toLowerCase();
        final queryLower = trimmedQuery.toLowerCase();

        return nameLower.contains(queryLower) ||
            descLower.contains(queryLower) ||
            categoryLower.contains(queryLower);
      }).toList();

      emit(SearchLoaded(results: results, query: trimmedQuery));
    } catch (e) {
      emit(SearchError('Search failed: $e'));
    }
  }

  /// Clear search and return to recent products
  void clearSearch() {
    loadRecentProducts();
  }
}
