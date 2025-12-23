import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  final String selectedPaymentMethod;

  const CheckoutInitial({this.selectedPaymentMethod = 'cash_on_delivery'});

  @override
  List<Object?> get props => [selectedPaymentMethod];
}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String orderId;

  const CheckoutSuccess(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentMethodSelected extends CheckoutState {
  final String selectedPaymentMethod;

  const PaymentMethodSelected(this.selectedPaymentMethod);

  @override
  List<Object?> get props => [selectedPaymentMethod];
}
