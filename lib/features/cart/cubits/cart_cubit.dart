import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  CartCubit() : super(CartInitial());

  // Cache for current cart data
  List<CartItemModel> _cachedItems = [];
  double _cachedTotal = 0.0;

  /// Load cart from Firestore
  Future<void> loadCart(String userId) async {
    try {
      emit(CartLoading());

      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data()))
          .toList();

      final totalPrice = _calculateTotal(items);

      // Update cache
      _cachedItems = items;
      _cachedTotal = totalPrice;

      emit(CartLoaded(items: items, totalPrice: totalPrice));
    } catch (e) {
      emit(
        CartError(
          'Failed to load cart: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
    }
  }

  /// Add product to cart
  Future<void> addToCart(
    String userId,
    ProductModel product, {
    int quantity = 1,
  }) async {
    try {
      // Show operation in progress
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'add',
          productId: product.id,
        ),
      );

      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(product.id);

      final doc = await docRef.get();

      CartItemModel newItem;

      if (doc.exists) {
        // Update existing item
        final existing = CartItemModel.fromJson(doc.data()!);
        newItem = existing.copyWith(quantity: existing.quantity + quantity);
        await docRef.update({
          'quantity': newItem.quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        newItem = CartItemModel(
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: quantity,
          rating: product.rating,
          reviewsCount: product.reviewsCount,
        );
        await docRef.set({
          ...newItem.toJson(),
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      // Reload to get fresh data
      await loadCart(userId);

      // Emit success state briefly
      final currentState = state;
      if (currentState is CartLoaded) {
        emit(
          CartItemAdded(
            item: newItem,
            allItems: currentState.items,
            totalPrice: currentState.totalPrice,
          ),
        );
        // Return to loaded state
        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState);
      }
    } catch (e) {
      emit(
        CartError(
          'Failed to add to cart: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
      // Restore previous state
      if (_cachedItems.isNotEmpty) {
        emit(CartLoaded(items: _cachedItems, totalPrice: _cachedTotal));
      }
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      // Show operation in progress
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'update',
          productId: productId,
        ),
      );

      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId);

      if (quantity <= 0) {
        // Remove item if quantity is 0 or negative
        await docRef.delete();
      } else {
        await docRef.update({
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      // Reload cart
      await loadCart(userId);
    } catch (e) {
      emit(
        CartError(
          'Failed to update quantity: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
      // Restore previous state
      if (_cachedItems.isNotEmpty) {
        emit(CartLoaded(items: _cachedItems, totalPrice: _cachedTotal));
      }
    }
  }

  /// Increment item quantity
  Future<void> incrementQuantity(String userId, String productId) async {
    final item = _cachedItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(userId, productId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(String userId, String productId) async {
    final item = _cachedItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(userId, productId, item.quantity - 1);
  }

  /// Remove item from cart
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      // Show operation in progress
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'remove',
          productId: productId,
        ),
      );

      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId);

      await docRef.delete();

      // Reload cart
      await loadCart(userId);

      // Emit success state briefly
      final currentState = state;
      if (currentState is CartLoaded) {
        emit(
          CartItemRemoved(
            productId: productId,
            remainingItems: currentState.items,
            totalPrice: currentState.totalPrice,
          ),
        );
        // Return to loaded state
        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState);
      }
    } catch (e) {
      emit(
        CartError(
          'Failed to remove item: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
      // Restore previous state
      if (_cachedItems.isNotEmpty) {
        emit(CartLoaded(items: _cachedItems, totalPrice: _cachedTotal));
      }
    }
  }

  /// Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      // Show operation in progress
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'clear',
        ),
      );

      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      // Delete all items in batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear cache
      _cachedItems = [];
      _cachedTotal = 0.0;

      emit(CartCleared());

      // Return to empty loaded state
      await Future.delayed(const Duration(milliseconds: 100));
      emit(CartLoaded(items: [], totalPrice: 0.0));
    } catch (e) {
      emit(
        CartError(
          'Failed to clear cart: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
      // Restore previous state
      if (_cachedItems.isNotEmpty) {
        emit(CartLoaded(items: _cachedItems, totalPrice: _cachedTotal));
      }
    }
  }

  /// Get cart item count
  int get itemCount {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.totalItems;
    }
    if (currentState is CartOperationInProgress) {
      return currentState.totalItems;
    }
    return 0;
  }

  /// Check if cart is empty
  bool get isEmpty {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.isEmpty;
    }
    return true;
  }

  /// Get specific item from cart
  CartItemModel? getItem(String productId) {
    return _cachedItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found'),
    );
  }

  /// Check if product is in cart
  bool hasProduct(String productId) {
    return _cachedItems.any((item) => item.productId == productId);
  }

  /// Get product quantity in cart
  int getProductQuantity(String productId) {
    try {
      final item = _cachedItems.firstWhere(
        (item) => item.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate total price
  double _calculateTotal(List<CartItemModel> items) {
    return items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// Refresh cart
  Future<void> refresh(String userId) async {
    await loadCart(userId);
  }
}
