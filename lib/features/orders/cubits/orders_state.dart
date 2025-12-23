import 'package:equatable/equatable.dart';
import '../models/order_model.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final String? filterStatus;

  const OrdersLoaded(this.orders, {this.filterStatus});

  List<OrderModel> get filteredOrders {
    if (filterStatus == null || filterStatus == 'all') {
      return orders;
    }
    return orders
        .where(
          (order) => order.status.toLowerCase() == filterStatus!.toLowerCase(),
        )
        .toList();
  }

  @override
  List<Object?> get props => [orders, filterStatus];
}

class OrderCreating extends OrdersState {}

class OrderCreated extends OrdersState {
  final OrderModel order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDetailsLoading extends OrdersState {}

class OrderDetailsLoaded extends OrdersState {
  final OrderModel order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
