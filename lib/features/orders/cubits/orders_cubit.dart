import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final FirebaseFirestore _firestore;

  OrdersCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(OrdersInitial());

  // Create new order
  Future<void> createOrder(OrderModel order) async {
    try {
      emit(OrderCreating());

      await _firestore
          .collection('orders')
          .doc(order.orderId)
          .set(order.toJson());

      emit(OrderCreated(order));
    } catch (e) {
      emit(OrdersError('Failed to create order: ${e.toString()}'));
    }
  }

  // Fetch all orders for a user
  Future<void> fetchUserOrders(String userId, {String? filterStatus}) async {
    try {
      emit(OrdersLoading());

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();

      emit(OrdersLoaded(orders, filterStatus: filterStatus));
    } catch (e) {
      emit(OrdersError('Failed to fetch orders: ${e.toString()}'));
    }
  }

  // Fetch single order by ID
  Future<void> fetchOrderById(String orderId) async {
    try {
      emit(OrderDetailsLoading());

      final docSnapshot = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();

      if (docSnapshot.exists) {
        final order = OrderModel.fromJson(docSnapshot.data()!);
        emit(OrderDetailsLoaded(order));
      } else {
        emit(const OrdersError('Order not found'));
      }
    } catch (e) {
      emit(OrdersError('Failed to fetch order: ${e.toString()}'));
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add specific timestamps based on status
      if (status.toLowerCase() == 'shipped') {
        updateData['shippedAt'] = FieldValue.serverTimestamp();
      } else if (status.toLowerCase() == 'delivered') {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      } else if (status.toLowerCase() == 'cancelled') {
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Refresh order details if currently viewing
      if (state is OrderDetailsLoaded) {
        await fetchOrderById(orderId);
      }
    } catch (e) {
      emit(OrdersError('Failed to update order status: ${e.toString()}'));
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
    } catch (e) {
      emit(OrdersError('Failed to cancel order: ${e.toString()}'));
    }
  }

  // Filter orders by status (client-side)
  void filterOrdersByStatus(String? status) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrdersLoaded(currentState.orders, filterStatus: status));
    }
  }

  // Stream orders in real-time
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
