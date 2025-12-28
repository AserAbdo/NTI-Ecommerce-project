import '../../cart/cubits/cart_state.dart';
import '../../coupons/models/coupon_model.dart';

/// Arguments passed from cart to checkout screen
/// Contains cart state and optional applied coupon
class CheckoutArguments {
  final CartLoaded cartState;
  final CouponModel? appliedCoupon;

  const CheckoutArguments({required this.cartState, this.appliedCoupon});
}
