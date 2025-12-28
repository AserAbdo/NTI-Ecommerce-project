import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../features/products/models/product_model.dart';

/// Repository for Products - handles data orchestration between remote and local sources
/// Implements offline-first pattern with automatic caching
class ProductRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  ProductRepository({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  /// Get products with offline-first approach
  /// Returns cached data first if available, then fetches fresh data
  Future<List<ProductModel>> getProducts({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    // Try to get cached data first
    if (!forceRefresh && await _localDataSource.hasProductsCache()) {
      return await _localDataSource.getCachedProducts();
    }

    try {
      // Fetch from remote
      final products = await _remoteDataSource.getProducts(limit: limit);

      // Cache the results
      await _localDataSource.cacheProducts(products);

      return products;
    } catch (e) {
      // If remote fails, try to return cached data
      final cachedProducts = await _localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }
      rethrow;
    }
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.getProductsByCategory(
        category,
        limit: limit,
      );
    } catch (e) {
      // Fallback to cached products filtered by category
      final cachedProducts = await _localDataSource.getCachedProducts();
      return cachedProducts.where((p) => p.category == category).toList();
    }
  }

  /// Get a single product by ID
  Future<ProductModel?> getProduct(String productId) async {
    // Try cache first
    final cached = await _localDataSource.getCachedProduct(productId);
    if (cached != null) {
      return cached;
    }

    // Fetch from remote
    return await _remoteDataSource.getProduct(productId);
  }

  /// Stream of products (real-time updates)
  Stream<List<ProductModel>> productsStream({int limit = 50}) {
    return _remoteDataSource.productsStream(limit: limit);
  }

  /// Search products locally
  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await _localDataSource.getCachedProducts();
    if (products.isEmpty) {
      // If no cache, fetch from remote first
      final remoteProducts = await _remoteDataSource.getProducts(limit: 100);
      await _localDataSource.cacheProducts(remoteProducts);
      return _filterByQuery(remoteProducts, query);
    }
    return _filterByQuery(products, query);
  }

  List<ProductModel> _filterByQuery(List<ProductModel> products, String query) {
    final q = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  /// Clear products cache
  Future<void> clearCache() async {
    final box = await _localDataSource.getCachedProducts();
    if (box.isNotEmpty) {
      await _localDataSource.cacheProducts([]);
    }
  }
}
