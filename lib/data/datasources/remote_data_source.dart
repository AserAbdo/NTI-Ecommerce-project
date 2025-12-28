import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/products/models/product_model.dart';
import '../../features/orders/models/order_model.dart';
import '../../features/coupons/models/coupon_model.dart';

/// Remote data source for Firebase operations
/// All network/Firestore calls go through here
class RemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // ==================== Auth ====================

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // ==================== Users ====================

  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: false));
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> userStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // ==================== Products ====================

  Future<List<ProductModel>> getProducts({int limit = 20}) async {
    final snapshot = await _firestore.collection('products').limit(limit).get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists && doc.data() != null) {
      return ProductModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  Stream<List<ProductModel>> productsStream({int limit = 50}) {
    return _firestore
        .collection('products')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // ==================== Orders ====================

  Future<void> createOrder(OrderModel order) async {
    await _firestore
        .collection('orders')
        .doc(order.orderId)
        .set(order.toJson());
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==================== Cart ====================

  Future<Map<String, dynamic>?> getCart(String userId) async {
    final doc = await _firestore.collection('carts').doc(userId).get();
    return doc.data();
  }

  Future<void> updateCart(String userId, Map<String, dynamic> cartData) async {
    await _firestore
        .collection('carts')
        .doc(userId)
        .set(cartData, SetOptions(merge: true));
  }

  Future<void> clearCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }

  Stream<Map<String, dynamic>?> cartStream(String userId) {
    return _firestore
        .collection('carts')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  // ==================== Favorites ====================

  Future<List<String>> getFavorites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addFavorite(
    String userId,
    String productId,
    Map<String, dynamic> productData,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set(productData);
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  Stream<List<String>> favoritesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // ==================== Coupons ====================

  Future<void> addCoupon(String userId, CouponModel coupon) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .doc(coupon.id)
        .set(coupon.toJson());
  }

  Future<List<CouponModel>> getUserCoupons(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .get();

    return snapshot.docs
        .map((doc) => CouponModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<CouponModel?> validateCoupon(String userId, String couponCode) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .where('code', isEqualTo: couponCode.toLowerCase())
        .where('isUsed', isEqualTo: false)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final coupon = CouponModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
      if (coupon.isValid) {
        return coupon;
      }
    }
    return null;
  }

  Future<void> markCouponUsed(String userId, String couponId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .doc(couponId)
        .update({'isUsed': true, 'usedAt': DateTime.now().toIso8601String()});
  }

  Stream<List<CouponModel>> userCouponsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CouponModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}
