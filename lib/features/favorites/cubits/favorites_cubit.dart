import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../products/models/product_model.dart';

class FavoritesCubit extends Cubit<Set<String>> {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final String userId;

  FavoritesCubit({required this.userId}) : super(<String>{}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('items')
          .get();
      final ids = snapshot.docs.map((d) => d.id).toSet();
      emit(ids);
    } catch (e) {
      // Silently fail, keep empty set
      emit(<String>{});
    }
  }

  bool isFavorite(String productId) => state.contains(productId);

  /// Stream of favorite products for displaying in FavoritesScreen
  Stream<List<ProductModel>> favoritesStream() {
    return _firestore
        .collection('favorites')
        .doc(userId)
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

  Future<void> toggleFavorite(ProductModel product) async {
    try {
      final docRef = _firestore
          .collection('favorites')
          .doc(userId)
          .collection('items')
          .doc(product.id);

      if (state.contains(product.id)) {
        // Remove favorite
        await docRef.delete();
        final newState = Set<String>.from(state)..remove(product.id);
        emit(newState);
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
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}
