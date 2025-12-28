import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _searchHistoryBox = 'search_history';
  static const String _recentProductsBox = 'recent_products';

  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  // Search History Methods
  static Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    final box = await Hive.openBox<String>(_searchHistoryBox);
    final queries = box.values.toList();
    queries.remove(query);
    queries.insert(0, query);
    if (queries.length > 10) {
      queries.removeRange(10, queries.length);
    }
    await box.clear();
    await box.addAll(queries);
  }

  static Future<List<String>> getSearchHistory() async {
    final box = await Hive.openBox<String>(_searchHistoryBox);
    return box.values.toList();
  }

  static Future<void> clearSearchHistory() async {
    final box = await Hive.openBox<String>(_searchHistoryBox);
    await box.clear();
  }

  static Future<void> saveSearchHistory(List<String> history) async {
    final box = await Hive.openBox<String>(_searchHistoryBox);
    await box.clear();
    await box.addAll(history);
  }

  // Recent Products Methods
  static Future<void> saveRecentProduct(String productId) async {
    final box = await Hive.openBox<String>(_recentProductsBox);
    final products = box.values.toList();

    products.remove(productId);
    products.insert(0, productId);

    if (products.length > 20) {
      products.removeRange(20, products.length);
    }

    await box.clear();
    await box.addAll(products);
  }

  static Future<List<String>> getRecentProducts() async {
    final box = await Hive.openBox<String>(_recentProductsBox);
    return box.values.toList();
  }

  static Future<void> clearRecentProducts() async {
    final box = await Hive.openBox<String>(_recentProductsBox);
    await box.clear();
  }
}
