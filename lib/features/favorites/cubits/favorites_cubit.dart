import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../products/models/product_model.dart';

class FavoritesCubit extends Cubit<Set<String>> {
  final FirebaseFirestore _firestore;
  String _userId;

  FavoritesCubit({required String userId, FirebaseFirestore? firestore})
    : _userId = userId,
      _firestore = firestore ?? FirebaseService.firestore,
      super(<String>{}) {
    if (_userId != 'guest') {
      _loadFavorites();
    }
  }

  String get userId => _userId;

  /// Update user ID when auth state changes
  /// Call this when user logs in or out
  void updateUserId(String newUserId) {
    if (_userId == newUserId) return;
    _userId = newUserId;
    if (_userId == 'guest') {
      emit(<String>{}); // Clear favorites for guest
    } else {
      _loadFavorites(); // Load favorites for logged-in user
    }
  }

  /// Clear favorites (call on logout)
  void clear() {
    emit(<String>{});
  }

  Future<void> _loadFavorites() async {
    if (_userId == 'guest') {
      emit(<String>{});
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .get();
      final ids = snapshot.docs.map((d) => d.id).toSet();
      emit(ids);
    } catch (e) {
      // Silently fail, keep empty set
      emit(<String>{});
    }
  }

  /// Reload favorites from server
  Future<void> reload() async {
    await _loadFavorites();
  }

  bool isFavorite(String productId) => state.contains(productId);

  /// Stream of favorite products for displaying in FavoritesScreen
  Stream<List<ProductModel>> favoritesStream() {
    if (_userId == 'guest') {
      return Stream.value([]);
    }

    return _firestore
        .collection('favorites')
        .doc(_userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Reconstruct ProductModel from saved data
            return ProductModel.fromJson({
              'id': doc.id,
              'name': data['name'] ?? '',
              'description': data['description'] ?? '',
              'price': (data['price'] ?? 0.0) is int
                  ? (data['price'] ?? 0).toDouble()
                  : (data['price'] ?? 0.0),
              'category': data['category'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
              'stock': data['stock'] ?? 0,
              'rating': (data['rating'] ?? 0.0) is int
                  ? (data['rating'] ?? 0).toDouble()
                  : (data['rating'] ?? 0.0),
              'reviewsCount': data['reviewsCount'] ?? 0,
              'oldPrice': data['oldPrice'] != null
                  ? ((data['oldPrice'] is int)
                        ? (data['oldPrice'] as int).toDouble()
                        : data['oldPrice'] as double)
                  : null,
              'newPrice': data['newPrice'] != null
                  ? ((data['newPrice'] is int)
                        ? (data['newPrice'] as int).toDouble()
                        : data['newPrice'] as double)
                  : null,
              'reviews': [], // Reviews not needed in favorites list
            });
          }).toList();
        });
  }

  /// Toggle favorite status. Returns true if added, false if removed.
  Future<bool> toggleFavorite(ProductModel product) async {
    if (_userId == 'guest') {
      throw Exception('Please login to add favorites');
    }

    try {
      final docRef = _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .doc(product.id);

      if (state.contains(product.id)) {
        // Remove favorite
        await docRef.delete();
        final newState = Set<String>.from(state)..remove(product.id);
        emit(newState);
        return false; // Removed from favorites
      } else {
        // Add favorite - save ALL product fields
        await docRef.set({
          'productId': product.id,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'stock': product.stock,
          'rating': product.rating,
          'reviewsCount': product.reviewsCount,
          'oldPrice': product.oldPrice,
          'newPrice': product.newPrice,
          'addedAt': FieldValue.serverTimestamp(),
        });
        final newState = Set<String>.from(state)..add(product.id);
        emit(newState);
        return true; // Added to favorites
      }
    } catch (e) {
      // Handle error - rethrow to let UI know
      rethrow;
    }
  }
}
