import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _progressTimer;

  Future<void> processPayment({
    required OrderModel order,
    required Function(OrderModel) onPaymentSuccess,
  }) async {
    try {
      emit(const PaymentProcessing(0.0));

      // Simulate payment processing with progress
      await _simulatePaymentProgress();

      // Generate transaction ID
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      final timestamp = DateTime.now();

      // Update order with payment info using copyWith
      final updatedOrder = order.copyWith(
        status: 'confirmed',
        paymentStatus: 'paid',
        paidAt: timestamp,
        updatedAt: timestamp,
      );

      // Call success callback
      await onPaymentSuccess(updatedOrder);

      emit(PaymentSuccess(transactionId: transactionId, timestamp: timestamp));
    } catch (e) {
      emit(PaymentFailed('Payment failed: $e'));
    }
  }

  Future<void> _simulatePaymentProgress() async {
    double progress = 0.0;

    _progressTimer?.cancel();

    // Create a completer to properly wait for timer completion
    final completer = Completer<void>();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      progress += 0.05;
      if (progress >= 1.0) {
        timer.cancel();
        progress = 1.0;
        emit(PaymentProcessing(progress));
        completer.complete();
      } else {
        emit(PaymentProcessing(progress));
      }
    });

    // Wait for timer to complete
    await completer.future;
    _progressTimer?.cancel();
  }

  void reset() {
    _progressTimer?.cancel();
    emit(PaymentInitial());
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    return super.close();
  }
}
