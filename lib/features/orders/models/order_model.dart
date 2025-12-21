import 'package:equatable/equatable.dart';
import '../../cart/models/cart_item_model.dart';

class OrderModel extends Equatable {
  final String orderId;
  final String userId;
  final List<CartItemModel> items;
  final double totalPrice;
  final String shippingAddress;
  final String status;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.shippingAddress,
    required this.status,
  });

  @override
  List<Object?> get props => [
    orderId,
    userId,
    items,
    totalPrice,
    shippingAddress,
    status,
  ];
}
