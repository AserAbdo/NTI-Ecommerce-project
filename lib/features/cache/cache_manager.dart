import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for product images
/// 
/// Configuration:
/// - Cache duration: 7 days
/// - Max cached objects: 200 images
/// - Automatic cleanup of old images
class CustomCacheManager extends CacheManager {
  static const key = 'vendora_image_cache';
  
  static CustomCacheManager? _instance;
  
  /// Singleton instance
  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }
  
  CustomCacheManager._()
      : super(
          Config(
            key,
            // How long to keep cached images
            stalePeriod: const Duration(days: 7),
            // Maximum number of images to cache
            maxNrOfCacheObjects: 200,
            // Repository for cache metadata
            repo: JsonCacheInfoRepository(databaseName: key),
            // File service for downloading
            fileService: HttpFileService(),
          ),
        );
  
  /// Clear all cached images
  /// Use this when you want to force refresh all images
  Future<void> clearAll() async {
    await emptyCache();
  }
  
  /// Remove a specific image from cache
  Future<void> removeImage(String url) async {
    await removeFile(url);
  }
  
  /// Get cache size information
  Future<Map<String, dynamic>> getCacheInfo() async {
    final files = await getFileFromCache(key);
    return {
      'exists': files != null,
      'validTill': files?.validTill.toIso8601String(),
    };
  }
}