import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../cart/cubits/cart_state.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  final CartLoaded cartState;

  const CheckoutScreen({Key? key, required this.cartState}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user.address != null) {
      _addressController.text = authState.user.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter shipping address')),
      );
      return;
    }
    setState(() {
      _isPlacingOrder = true;
    });
    try {
      final userId = authState.user.id;
      final items = widget.cartState.items;
      final totalPrice = widget.cartState.totalPrice;
      final shippingAddress = _addressController.text.trim();
      final firestore = FirebaseFirestore.instance;
      final orderRef = firestore.collection('orders').doc();
      await orderRef.set({
        'orderId': orderRef.id,
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalPrice': totalPrice,
        'shippingAddress': shippingAddress,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear Cart from Firestore after order creation
      await context.read<CartCubit>().clearCart(userId);
      // Reload Cart to show empty state
      await context.read<CartCubit>().loadCart(userId);
      final orderModel = OrderModel(
        orderId: orderRef.id,
        userId: userId,
        items: items,
        totalPrice: totalPrice,
        shippingAddress: shippingAddress,
        status: 'Pending',
      );
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.orderConfirmation,
          arguments: orderModel,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cartState.items;
    final totalPrice = widget.cartState.totalPrice;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Text(
              AppStrings.orderSummary,
              style: TextStyle(
                fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final itemTotal = item.price * item.quantity;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${itemTotal.toStringAsFixed(0)} ${AppStrings.egp}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.total,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Address
            Text(
              AppStrings.shippingAddress,
              style: TextStyle(
                fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your full shipping address',
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: AppStrings.placeOrder,
              onPressed: _isPlacingOrder ? () {} : _placeOrder,
              isLoading: _isPlacingOrder,
            ),
          ],
        ),
      ),
    );
  }
}
