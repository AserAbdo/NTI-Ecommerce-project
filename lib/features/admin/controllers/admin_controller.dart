import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';

/// Controller for admin dashboard operations
class AdminController {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Get stream of dashboard statistics
  static Stream<AdminStats> getStatsStream() {
    return _firestore.collection('orders').snapshots().asyncMap((
      ordersSnapshot,
    ) async {
      final productsSnapshot = await _firestore.collection('products').get();

      double totalRevenue = 0;
      int pendingOrders = 0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
        if (data['status'] == 'pending') pendingOrders++;
      }

      return AdminStats(
        totalRevenue: totalRevenue,
        totalOrders: ordersSnapshot.docs.length,
        totalProducts: productsSnapshot.docs.length,
        pendingOrders: pendingOrders,
      );
    });
  }

  /// Delete a product by ID
  static Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  /// Create a new product
  static Future<void> createProduct(Map<String, dynamic> productData) async {
    productData['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').add(productData);
  }

  /// Update an existing product
  static Future<void> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    productData['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').doc(productId).update(productData);
  }

  /// Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get orders stream with optional status filter
  static Stream<QuerySnapshot> getOrdersStream({String? statusFilter}) {
    if (statusFilter == null || statusFilter == 'All') {
      return _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: statusFilter)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get products stream
  static Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').orderBy('name').snapshots();
  }
}

/// Data class for admin dashboard statistics
class AdminStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int pendingOrders;

  const AdminStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.pendingOrders,
  });

  factory AdminStats.empty() => const AdminStats(
    totalRevenue: 0,
    totalOrders: 0,
    totalProducts: 0,
    pendingOrders: 0,
  );
}
