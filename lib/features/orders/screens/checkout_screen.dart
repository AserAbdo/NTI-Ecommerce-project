import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/order_utils.dart';
import '../../../services/local_notification_service.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../cart/cubits/cart_state.dart';
import '../../coupons/models/coupon_model.dart';
import '../../coupons/services/coupon_service.dart';
import '../models/order_model.dart';
import '../models/shipping_address_model.dart';
import '../cubits/orders_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final CartLoaded cartState;

  const CheckoutScreen({super.key, required this.cartState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping address controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();

  String _selectedPaymentMethod = 'cash_on_delivery';
  bool _isPlacingOrder = false;
  bool _isApplyingCoupon = false;
  CouponModel? _appliedCoupon;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash_on_delivery',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'color': Colors.green,
    },
    {
      'id': 'credit_card',
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _fullNameController.text = authState.user.name;
      _phoneController.text = authState.user.phone;
      if (authState.user.address.isNotEmpty) {
        _streetController.text = authState.user.address;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toLowerCase();
    if (code.isEmpty) {
      _showSnackBar('Please enter a coupon code', isError: true);
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      final coupon = await CouponService.validateCoupon(
        authState.user.id,
        code,
      );

      if (coupon != null) {
        setState(() {
          _appliedCoupon = coupon;
        });
        _showSnackBar(
          '🎉 Coupon applied! ${coupon.discountPercentage.toInt()}% discount',
        );
      } else {
        _showSnackBar('Invalid or expired coupon code', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error applying coupon: $e', isError: true);
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
    });
    _showSnackBar('Coupon removed');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  double get _discountAmount {
    if (_appliedCoupon == null) return 0;
    return widget.cartState.totalPrice *
        (_appliedCoupon!.discountPercentage / 100);
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final userId = authState.user.id;
      final items = widget.cartState.items;

      // Calculate pricing with discount
      final subtotal = widget.cartState.totalPrice;
      final discount = _discountAmount;
      final taxableAmount = subtotal - discount;
      final tax = OrderUtils.calculateTax(
        taxableAmount > 0 ? taxableAmount : 0,
      );
      final shippingFee = OrderUtils.calculateShippingFee(
        city: _cityController.text,
      );
      final totalPrice = taxableAmount + tax + shippingFee;

      // Mark coupon as used if applied and show notification
      if (_appliedCoupon != null) {
        await CouponService.useCoupon(userId, _appliedCoupon!.id);
        // Show celebratory notification for savings!
        await LocalNotificationService.showCouponUsedNotification(
          couponCode: _appliedCoupon!.code,
          savedAmount: discount,
        );
      }

      // Create shipping address
      final shippingAddress = ShippingAddressModel(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        apartment: _apartmentController.text.trim().isNotEmpty
            ? _apartmentController.text.trim()
            : null,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: 'Egypt',
        isDefault: false,
      );

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
        customerName: authState.user.name,
        customerEmail: authState.user.email,
        customerPhone: authState.user.phone,
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: _selectedPaymentMethod,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shippingFee: shippingFee,
        discount: discount,
        totalPrice: totalPrice,
        currency: 'EGP',
        shippingAddress: shippingAddress,
        estimatedDeliveryDate: estimatedDelivery,
        trackingNumber: trackingNumber,
        customerNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: now,
        updatedAt: now,
      );

      // Save order
      await context.read<OrdersCubit>().createOrder(order);

      // Clear cart
      await context.read<CartCubit>().clearCart(userId);
      await context.read<CartCubit>().loadCart(userId);

      if (mounted) {
        // Cash on Delivery: Go directly to confirmation
        if (_selectedPaymentMethod == 'cash_on_delivery') {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.orderConfirmation,
            arguments: order.copyWith(
              paymentStatus: 'pending', // COD payment is pending until delivery
            ),
          );
        } else {
          // Visa/PayPal: Go to payment screen
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.mockPayment,
            arguments: order,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    final subtotal = widget.cartState.totalPrice;
    final discount = _discountAmount;
    final taxableAmount = subtotal - discount;
    final tax = OrderUtils.calculateTax(taxableAmount > 0 ? taxableAmount : 0);
    final shippingFee = OrderUtils.calculateShippingFee();
    final total = taxableAmount + tax + shippingFee;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          children: [
            // Shipping Address Section
            _buildSectionCard(
              title: 'Shipping Address',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!OrderUtils.isValidPhone(value!)) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _streetController,
                    label: 'Street Address',
                    icon: Icons.home_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _apartmentController,
                    label: 'Apartment / Unit (Optional)',
                    icon: Icons.apartment_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_outlined,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.map_outlined,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Coupon Code Section
            _buildCouponSection(),

            const SizedBox(height: 20),

            // Payment Method Section
            _buildSectionCard(
              title: 'Payment Method',
              icon: Icons.payment_outlined,
              child: Column(
                children: _paymentMethods.map((method) {
                  return _buildPaymentMethodTile(
                    id: method['id'],
                    name: method['name'],
                    icon: method['icon'],
                    color: method['color'],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Order Summary Section
            _buildSectionCard(
              title: 'Order Summary',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  ...widget.cartState.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color ??
                                        AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'EGP ${(item.price * item.quantity).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color ??
                                  AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildPriceRow('Subtotal', subtotal),
                  if (_appliedCoupon != null) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Discount (${_appliedCoupon!.discountPercentage.toInt()}%)',
                      -discount,
                      color: AppColors.success,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPriceRow('Tax (10%)', tax),
                  const SizedBox(height: 8),
                  _buildPriceRow('Shipping Fee', shippingFee),
                  const Divider(height: 24),
                  _buildPriceRow('Total', total, isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notes Section
            _buildSectionCard(
              title: 'Order Notes (Optional)',
              icon: Icons.note_outlined,
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any special instructions...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildSectionCard(
      title: 'Coupon Code',
      icon: Icons.local_offer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedCoupon == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Theme.of(context).cardColor.withOpacity(0.5)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isApplyingCoupon ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isApplyingCoupon
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Apply',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Try: elzoz2026 for 50% off!',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.15),
                    AppColors.success.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _appliedCoupon!.code.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_appliedCoupon!.discountPercentage.toInt()}% OFF',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You save EGP ${_discountAmount.toStringAsFixed(0)}!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeCoupon,
                    icon: Icon(Icons.close_rounded, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor.withOpacity(0.5)
            : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).cardColor.withOpacity(0.5)
                    : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? color
                      : (Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.textPrimary),
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color:
                color ??
                (isTotal
                    ? (Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textPrimary)
                    : AppColors.textSecondary),
          ),
        ),
        Text(
          '${amount < 0 ? "-" : ""}EGP ${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.w800,
            color:
                color ??
                (isTotal
                    ? AppColors.primary
                    : (Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textPrimary)),
          ),
        ),
      ],
    );
  }
}
