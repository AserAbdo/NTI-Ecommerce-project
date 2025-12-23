import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/order_utils.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/shipping_address_model.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(const CheckoutInitial());

  void selectPaymentMethod(String method) {
    emit(PaymentMethodSelected(method));
  }

  String get selectedPaymentMethod {
    final currentState = state;
    if (currentState is PaymentMethodSelected) {
      return currentState.selectedPaymentMethod;
    }
    if (currentState is CheckoutInitial) {
      return currentState.selectedPaymentMethod;
    }
    return 'cash_on_delivery';
  }

  Future<void> placeOrder({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required List<CartItemModel> items,
    required double subtotal,
    required ShippingAddressModel shippingAddress,
    String? customerNotes,
    required Function(OrderModel) onOrderCreated,
  }) async {
    try {
      emit(CheckoutLoading());

      // Calculate pricing
      final tax = OrderUtils.calculateTax(subtotal);
      final shippingFee = OrderUtils.calculateShippingFee(
        city: shippingAddress.city,
      );
      final totalPrice = subtotal + tax + shippingFee;

      // Generate order details
      final orderNumber = OrderUtils.generateOrderNumber();
      final trackingNumber = OrderUtils.generateTrackingNumber();
      final now = DateTime.now();
      final estimatedDelivery = OrderUtils.getEstimatedDeliveryDate(now);

      // Create order
      final order = OrderModel(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: orderNumber,
        userId: userId,
        customerName: userName,
        customerEmail: userEmail,
        customerPhone: userPhone,
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: selectedPaymentMethod,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shippingFee: shippingFee,
        discount: 0.0,
        totalPrice: totalPrice,
        currency: 'EGP',
        shippingAddress: shippingAddress,
        estimatedDeliveryDate: estimatedDelivery,
        trackingNumber: trackingNumber,
        customerNotes: customerNotes,
        createdAt: now,
        updatedAt: now,
      );

      // Call the callback to save order
      await onOrderCreated(order);

      emit(CheckoutSuccess(order.orderId));
    } catch (e) {
      emit(CheckoutError('Failed to place order: $e'));
    }
  }

  void reset() {
    emit(const CheckoutInitial());
  }
}
