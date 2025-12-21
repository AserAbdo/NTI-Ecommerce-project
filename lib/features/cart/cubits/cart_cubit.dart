import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  CartCubit() : super(CartInitial());

  String? _getUserId(BlocBase authCubit) {
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      return state.user.id;
    }
    return null;
  }

  Future<void> loadCart(String userId) async {
    try {
      emit(CartLoading());
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      final items = snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data()))
          .toList();
      final totalPrice = items.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      emit(CartLoaded(items: items, totalPrice: totalPrice));
    } catch (e) {
      emit(CartError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> addToCart(
    String userId,
    ProductModel product, {
    int quantity = 1,
  }) async {
    try {
      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(product.id);
      final doc = await docRef.get();
      if (doc.exists) {
        final existing = CartItemModel.fromJson(doc.data()!);
        final updated = existing.copyWith(
          quantity: existing.quantity + quantity,
        );
        await docRef.update({
          'quantity': updated.quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final item = CartItemModel(
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: quantity,
        );
        await docRef.set({
          ...item.toJson(),
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      emit(CartError('Failed to add to cart: ${e.toString()}'));
    }
  }

  Future<void> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId);
      if (quantity <= 0) {
        await docRef.delete();
      } else {
        await docRef.update({
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      emit(CartError('Failed to update quantity: ${e.toString()}'));
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    try {
      final docRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId);
      await docRef.delete();
    } catch (e) {
      emit(CartError('Failed to remove item: ${e.toString()}'));
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }
}
