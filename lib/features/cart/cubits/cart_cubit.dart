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

  /// Load cart from Firestore - items stored directly in document
  Future<void> loadCart(String userId) async {
    try {
      emit(CartLoading());

      final doc = await _firestore.collection('carts').doc(userId).get();

      List<CartItemModel> items = [];

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final productsArray = data['products'] as List<dynamic>? ?? [];

        items = productsArray
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

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

  /// Add product to cart - stored in products array
  Future<void> addToCart(
    String userId,
    ProductModel product, {
    int quantity = 1,
  }) async {
    try {
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'add',
          productId: product.id,
        ),
      );

      final docRef = _firestore.collection('carts').doc(userId);
      final doc = await docRef.get();

      List<Map<String, dynamic>> products = [];

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        products = List<Map<String, dynamic>>.from(
          (data['products'] as List<dynamic>? ?? []).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
      }

      // Check if product already exists
      final existingIndex = products.indexWhere(
        (item) => item['productId'] == product.id,
      );

      CartItemModel newItem;

      if (existingIndex >= 0) {
        // Update quantity
        final currentQty = products[existingIndex]['quantity'] as int? ?? 0;
        products[existingIndex]['quantity'] = currentQty + quantity;
        newItem = CartItemModel.fromJson(products[existingIndex]);
      } else {
        // Add new item
        newItem = CartItemModel(
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: quantity,
          description: product.description,
        );
        products.add(newItem.toJson());
      }

      // Save to Firestore
      await docRef.set({
        'products': products,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Reload cart
      await loadCart(userId);

      // Emit success
      final currentState = state;
      if (currentState is CartLoaded) {
        emit(
          CartItemAdded(
            item: newItem,
            allItems: currentState.items,
            totalPrice: currentState.totalPrice,
          ),
        );
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
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'update',
          productId: productId,
        ),
      );

      final docRef = _firestore.collection('carts').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Cart not found');
      }

      final data = doc.data()!;
      List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
        (data['products'] as List<dynamic>? ?? []).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      if (quantity <= 0) {
        // Remove item
        products.removeWhere((item) => item['productId'] == productId);
      } else {
        // Update quantity
        final index = products.indexWhere(
          (item) => item['productId'] == productId,
        );
        if (index >= 0) {
          products[index]['quantity'] = quantity;
        }
      }

      await docRef.update({
        'products': products,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadCart(userId);
    } catch (e) {
      emit(
        CartError(
          'Failed to update quantity: ${e.toString()}',
          previousItems: _cachedItems,
          previousTotal: _cachedTotal,
        ),
      );
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
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'remove',
          productId: productId,
        ),
      );

      final docRef = _firestore.collection('carts').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Cart not found');
      }

      final data = doc.data()!;
      List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
        (data['products'] as List<dynamic>? ?? []).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      products.removeWhere((item) => item['productId'] == productId);

      await docRef.update({
        'products': products,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadCart(userId);

      final currentState = state;
      if (currentState is CartLoaded) {
        emit(
          CartItemRemoved(
            productId: productId,
            remainingItems: currentState.items,
            totalPrice: currentState.totalPrice,
          ),
        );
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
      if (_cachedItems.isNotEmpty) {
        emit(CartLoaded(items: _cachedItems, totalPrice: _cachedTotal));
      }
    }
  }

  /// Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      emit(
        CartOperationInProgress(
          items: _cachedItems,
          totalPrice: _cachedTotal,
          operationType: 'clear',
        ),
      );

      await _firestore.collection('carts').doc(userId).set({
        'products': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _cachedItems = [];
      _cachedTotal = 0.0;

      emit(CartCleared());

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
    try {
      return _cachedItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
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
