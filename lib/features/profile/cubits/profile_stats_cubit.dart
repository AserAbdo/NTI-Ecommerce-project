import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State for Profile Statistics
class ProfileStatsState extends Equatable {
  final int ordersCount;
  final int favoritesCount;
  final int couponsCount;
  final bool isLoading;
  final String? error;

  const ProfileStatsState({
    this.ordersCount = 0,
    this.favoritesCount = 0,
    this.couponsCount = 0,
    this.isLoading = true,
    this.error,
  });

  ProfileStatsState copyWith({
    int? ordersCount,
    int? favoritesCount,
    int? couponsCount,
    bool? isLoading,
    String? error,
  }) {
    return ProfileStatsState(
      ordersCount: ordersCount ?? this.ordersCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      couponsCount: couponsCount ?? this.couponsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    ordersCount,
    favoritesCount,
    couponsCount,
    isLoading,
    error,
  ];
}

/// Cubit to manage profile statistics with proper stream handling
class ProfileStatsCubit extends Cubit<ProfileStatsState> {
  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  StreamSubscription<QuerySnapshot>? _couponsSubscription;

  String? _currentUserId;

  ProfileStatsCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ProfileStatsState());

  /// Load stats for a user
  void loadStats(String userId) {
    if (_currentUserId == userId) return; // Already loaded for this user

    // Cancel existing subscriptions
    _cancelSubscriptions();

    _currentUserId = userId;
    emit(state.copyWith(isLoading: true));

    // Subscribe to orders count
    _ordersSubscription = _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            emit(
              state.copyWith(
                ordersCount: snapshot.docs.length,
                isLoading: false,
              ),
            );
          },
          onError: (e) {
            emit(state.copyWith(error: 'Failed to load orders count'));
          },
        );

    // Subscribe to favorites count
    _favoritesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            emit(
              state.copyWith(
                favoritesCount: snapshot.docs.length,
                isLoading: false,
              ),
            );
          },
          onError: (e) {
            emit(state.copyWith(error: 'Failed to load favorites count'));
          },
        );

    // Subscribe to coupons count (only valid, unused coupons)
    _couponsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .where('isUsed', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            // Filter for valid coupons (not expired)
            final now = DateTime.now();
            final validCount = snapshot.docs.where((doc) {
              final data = doc.data();
              final expiresAt = data['expiresAt'] != null
                  ? DateTime.tryParse(data['expiresAt'].toString())
                  : null;
              return expiresAt == null || expiresAt.isAfter(now);
            }).length;

            emit(state.copyWith(couponsCount: validCount, isLoading: false));
          },
          onError: (e) {
            emit(state.copyWith(error: 'Failed to load coupons count'));
          },
        );
  }

  /// Clear stats (e.g., on logout)
  void clearStats() {
    _cancelSubscriptions();
    _currentUserId = null;
    emit(const ProfileStatsState(isLoading: false));
  }

  void _cancelSubscriptions() {
    _ordersSubscription?.cancel();
    _favoritesSubscription?.cancel();
    _couponsSubscription?.cancel();
    _ordersSubscription = null;
    _favoritesSubscription = null;
    _couponsSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
