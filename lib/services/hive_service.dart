import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _searchHistoryBox = 'search_history';

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
}
