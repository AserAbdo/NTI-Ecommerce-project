import 'package:equatable/equatable.dart';
import '../models/cart_item_model.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;

  CartLoaded({required this.items, required this.totalPrice});

  @override
  List<Object?> get props => [items, totalPrice];
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}
