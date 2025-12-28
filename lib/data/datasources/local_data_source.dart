import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/products/models/product_model.dart';
import '../../features/orders/models/order_model.dart';
import '../../features/auth/models/user_model.dart';

/// Local data source for Hive caching
/// Provides offline support and fast data access
class LocalDataSource {
  static const String _productsBoxName = 'products_cache';
  static const String _ordersBoxName = 'orders_cache';
  static const String _userBoxName = 'user_cache';
  static const String _favoritesBoxName = 'favorites_cache';
  static const String _cartBoxName = 'cart_cache';
  static const String _settingsBoxName = 'settings';

  Box<String>? _productsBox;
  Box<String>? _ordersBox;
  Box<String>? _userBox;
  Box<String>? _favoritesBox;
  Box<String>? _cartBox;
  Box<dynamic>? _settingsBox;

  /// Initialize all Hive boxes
  Future<void> initialize() async {
    _productsBox = await Hive.openBox<String>(_productsBoxName);
    _ordersBox = await Hive.openBox<String>(_ordersBoxName);
    _userBox = await Hive.openBox<String>(_userBoxName);
    _favoritesBox = await Hive.openBox<String>(_favoritesBoxName);
    _cartBox = await Hive.openBox<String>(_cartBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // ==================== Products ====================

  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = _productsBox ?? await Hive.openBox<String>(_productsBoxName);
    await box.clear();
    for (final product in products) {
      await box.put(product.id, jsonEncode(product.toJson()));
    }
    await _setLastCacheTime('products');
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final box = _productsBox ?? await Hive.openBox<String>(_productsBoxName);
    final products = <ProductModel>[];
    for (final key in box.keys) {
      final json = box.get(key);
      if (json != null) {
        products.add(ProductModel.fromJson(jsonDecode(json)));
      }
    }
    return products;
  }

  Future<ProductModel?> getCachedProduct(String productId) async {
    final box = _productsBox ?? await Hive.openBox<String>(_productsBoxName);
    final json = box.get(productId);
    if (json != null) {
      return ProductModel.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<bool> hasProductsCache() async {
    final box = _productsBox ?? await Hive.openBox<String>(_productsBoxName);
    return box.isNotEmpty && !_isCacheExpired('products');
  }

  // ==================== Orders ====================

  Future<void> cacheOrders(String userId, List<OrderModel> orders) async {
    final box = _ordersBox ?? await Hive.openBox<String>(_ordersBoxName);
    await box.put(userId, jsonEncode(orders.map((o) => o.toJson()).toList()));
    await _setLastCacheTime('orders_$userId');
  }

  Future<List<OrderModel>> getCachedOrders(String userId) async {
    final box = _ordersBox ?? await Hive.openBox<String>(_ordersBoxName);
    final json = box.get(userId);
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> hasOrdersCache(String userId) async {
    final box = _ordersBox ?? await Hive.openBox<String>(_ordersBoxName);
    return box.containsKey(userId) && !_isCacheExpired('orders_$userId');
  }

  // ==================== User ====================

  Future<void> cacheUser(UserModel user) async {
    final box = _userBox ?? await Hive.openBox<String>(_userBoxName);
    await box.put('current_user', jsonEncode(user.toJson()));
  }

  Future<UserModel?> getCachedUser() async {
    final box = _userBox ?? await Hive.openBox<String>(_userBoxName);
    final json = box.get('current_user');
    if (json != null) {
      return UserModel.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> clearUserCache() async {
    final box = _userBox ?? await Hive.openBox<String>(_userBoxName);
    await box.clear();
  }

  // ==================== Favorites ====================

  Future<void> cacheFavorites(String userId, List<String> productIds) async {
    final box = _favoritesBox ?? await Hive.openBox<String>(_favoritesBoxName);
    await box.put(userId, jsonEncode(productIds));
  }

  Future<List<String>> getCachedFavorites(String userId) async {
    final box = _favoritesBox ?? await Hive.openBox<String>(_favoritesBoxName);
    final json = box.get(userId);
    if (json != null) {
      return List<String>.from(jsonDecode(json));
    }
    return [];
  }

  Future<void> addToFavorites(String userId, String productId) async {
    final favorites = await getCachedFavorites(userId);
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await cacheFavorites(userId, favorites);
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    final favorites = await getCachedFavorites(userId);
    favorites.remove(productId);
    await cacheFavorites(userId, favorites);
  }

  // ==================== Cart ====================

  Future<void> cacheCart(String userId, Map<String, dynamic> cartData) async {
    final box = _cartBox ?? await Hive.openBox<String>(_cartBoxName);
    await box.put(userId, jsonEncode(cartData));
  }

  Future<Map<String, dynamic>?> getCachedCart(String userId) async {
    final box = _cartBox ?? await Hive.openBox<String>(_cartBoxName);
    final json = box.get(userId);
    if (json != null) {
      return Map<String, dynamic>.from(jsonDecode(json));
    }
    return null;
  }

  Future<void> clearCart(String userId) async {
    final box = _cartBox ?? await Hive.openBox<String>(_cartBoxName);
    await box.delete(userId);
  }

  // ==================== Settings & Cache Management ====================

  Future<void> _setLastCacheTime(String key) async {
    final box = _settingsBox ?? await Hive.openBox(_settingsBoxName);
    await box.put('cache_time_$key', DateTime.now().millisecondsSinceEpoch);
  }

  bool _isCacheExpired(
    String key, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    final box = _settingsBox;
    if (box == null) return true;
    final lastCacheTime = box.get('cache_time_$key');
    if (lastCacheTime == null) return true;
    final age = DateTime.now().millisecondsSinceEpoch - (lastCacheTime as int);
    return age > maxAge.inMilliseconds;
  }

  Future<void> clearAllCache() async {
    await _productsBox?.clear();
    await _ordersBox?.clear();
    await _userBox?.clear();
    await _favoritesBox?.clear();
    await _cartBox?.clear();
  }

  /// Check if we have any cached data to work offline
  Future<bool> hasOfflineData() async {
    final hasProducts = await hasProductsCache();
    return hasProducts;
  }
}
