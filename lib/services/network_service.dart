import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring network connectivity status
class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();

  NetworkService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectivityController = StreamController<bool>.broadcast();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the network service
  Future<void> initialize() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectivity(results);
    });

    if (kDebugMode) {
      debugPrint('✅ Network service initialized (connected: $_isConnected)');
    }
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      if (kDebugMode) {
        debugPrint(
          _isConnected ? '🌐 Network connected' : '📴 Network disconnected',
        );
      }
    }
  }

  /// Check if currently connected to the internet
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);
    return _isConnected;
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
