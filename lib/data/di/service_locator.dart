import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';
import '../../services/network_service.dart';

/// Service Locator / Dependency Injection Container
/// Provides singleton instances of all data layer dependencies
class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();

  ServiceLocator._();

  // Data Sources
  late final RemoteDataSource _remoteDataSource;
  late final LocalDataSource _localDataSource;

  // Repositories
  late final AuthRepository _authRepository;
  late final ProductRepository _productRepository;

  // Services
  late final NetworkService _networkService;

  bool _isInitialized = false;

  /// Initialize all dependencies
  Future<void> initialize({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) async {
    if (_isInitialized) return;

    // Initialize network service first
    _networkService = NetworkService.instance;
    await _networkService.initialize();

    // Initialize data sources
    _remoteDataSource = RemoteDataSource(firestore: firestore, auth: auth);

    _localDataSource = LocalDataSource();
    await _localDataSource.initialize();

    // Initialize repositories
    _authRepository = AuthRepository(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    _productRepository = ProductRepository(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('✅ ServiceLocator dependencies initialized');
    }
  }

  // ==================== Getters ====================

  RemoteDataSource get remoteDataSource {
    _checkInitialized();
    return _remoteDataSource;
  }

  LocalDataSource get localDataSource {
    _checkInitialized();
    return _localDataSource;
  }

  AuthRepository get authRepository {
    _checkInitialized();
    return _authRepository;
  }

  ProductRepository get productRepository {
    _checkInitialized();
    return _productRepository;
  }

  NetworkService get networkService {
    _checkInitialized();
    return _networkService;
  }

  /// Check if currently connected to the network
  bool get isOnline => _networkService.isConnected;

  // ==================== Helpers ====================

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'ServiceLocator not initialized. Call ServiceLocator.instance.initialize() first.',
      );
    }
  }

  /// Reset for testing
  static void reset() {
    _instance = null;
  }
}

/// Convenience getters for quick access
RemoteDataSource get remoteDataSource =>
    ServiceLocator.instance.remoteDataSource;
LocalDataSource get localDataSource => ServiceLocator.instance.localDataSource;
AuthRepository get authRepository => ServiceLocator.instance.authRepository;
ProductRepository get productRepository =>
    ServiceLocator.instance.productRepository;
NetworkService get networkService => ServiceLocator.instance.networkService;
bool get isOnline => ServiceLocator.instance.isOnline;
