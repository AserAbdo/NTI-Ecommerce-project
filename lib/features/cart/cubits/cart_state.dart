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
  final int totalItems;
  final bool isEmpty;

  CartLoaded({required this.items, required this.totalPrice})
    : totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity),
      isEmpty = items.isEmpty;

  @override
  List<Object?> get props => [items, totalPrice, totalItems, isEmpty];

  CartLoaded copyWith({List<CartItemModel>? items, double? totalPrice}) {
    return CartLoaded(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class CartOperationInProgress extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;
  final int totalItems;
  final String operationType;
  final String? productId;

  CartOperationInProgress({
    required this.items,
    required this.totalPrice,
    required this.operationType,
    this.productId,
  }) : totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
    items,
    totalPrice,
    totalItems,
    operationType,
    productId,
  ];
}

class CartError extends CartState {
  final String message;
  final List<CartItemModel>? previousItems;
  final double? previousTotal;

  CartError(this.message, {this.previousItems, this.previousTotal});

  @override
  List<Object?> get props => [message, previousItems, previousTotal];
}

class CartItemAdded extends CartState {
  final CartItemModel item;
  final List<CartItemModel> allItems;
  final double totalPrice;

  CartItemAdded({
    required this.item,
    required this.allItems,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [item, allItems, totalPrice];
}

class CartItemRemoved extends CartState {
  final String productId;
  final List<CartItemModel> remainingItems;
  final double totalPrice;

  CartItemRemoved({
    required this.productId,
    required this.remainingItems,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [productId, remainingItems, totalPrice];
}

class CartCleared extends CartState {}
