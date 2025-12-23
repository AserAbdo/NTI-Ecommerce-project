import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentProcessing extends PaymentState {
  final double progress;

  const PaymentProcessing(this.progress);

  @override
  List<Object?> get props => [progress];
}

class PaymentSuccess extends PaymentState {
  final String transactionId;
  final DateTime timestamp;

  const PaymentSuccess({required this.transactionId, required this.timestamp});

  @override
  List<Object?> get props => [transactionId, timestamp];
}

class PaymentFailed extends PaymentState {
  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}
