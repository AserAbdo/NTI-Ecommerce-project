import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nti_project/core/firebase/firebase_options.dart';

import '../../features/chatbot/models/chat_message.dart';
import '../../features/cache/cache_manager.dart';
import '../../services/hive_service.dart';

/// Handles all app initialization tasks
class AppInitializer {
  AppInitializer._();

  /// Initialize all required services
  static Future<void> initialize() async {
    try {
      await _initializeFirebase();
      await _initializeHive();
      _initializeCache();

      if (kDebugMode) {
        debugPrint('✅ All services initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing services: $e');
      }
      rethrow;
    }
  }

  /// Initialize Firebase
  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized');
    }
  }

  /// Initialize Hive local storage
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    await HiveService.initialize();
    Hive.registerAdapter(ChatMessageAdapter());
    if (kDebugMode) {
      debugPrint('✅ Hive initialized');
    }
  }

  /// Initialize cache manager
  static void _initializeCache() {
    CustomCacheManager();
    if (kDebugMode) {
      debugPrint('✅ Cache manager initialized');
    }
  }
}
