import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/order_model.dart';

class MockPaymentScreen extends StatefulWidget {
  final OrderModel order;

  const MockPaymentScreen({super.key, required this.order});

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;
  bool _paymentSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing (2-3 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });

    // Start success animation
    _animationController.forward();

    // Navigate to order confirmation after showing success
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.orderConfirmation,
        arguments: widget.order.copyWith(
          paymentStatus: 'paid',
          paidAt: DateTime.now(),
        ),
      );
    }
  }

  String _getPaymentMethodName() {
    switch (widget.order.paymentMethod) {
      case 'credit_card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      default:
        return 'Payment';
    }
  }

  Color _getPaymentColor() {
    switch (widget.order.paymentMethod) {
      case 'credit_card':
        return Colors.blue;
      case 'paypal':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getPaymentMethodName()),
        backgroundColor: _getPaymentColor(),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !_isProcessing && !_paymentSuccess,
      ),
      body: SafeArea(
        child: _paymentSuccess ? _buildSuccessView() : _buildPaymentForm(),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Payment Card Preview
            _buildCardPreview(),

            const SizedBox(height: 32),

            // Order Amount
            _buildAmountSection(),

            const SizedBox(height: 32),

            // Card Details Form
            Text(
              'Card Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Card Number
            _buildCardNumberField(),
            const SizedBox(height: 16),

            // Card Holder Name
            _buildCardHolderField(),
            const SizedBox(height: 16),

            // Expiry and CVV
            Row(
              children: [
                Expanded(child: _buildExpiryField()),
                const SizedBox(width: 16),
                Expanded(child: _buildCVVField()),
              ],
            ),

            const SizedBox(height: 32),

            // Pay Button or Processing Indicator
            if (!_isProcessing)
              _buildPayButton()
            else
              _buildProcessingIndicator(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getPaymentColor(), _getPaymentColor().withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getPaymentColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  widget.order.paymentMethod == 'paypal'
                      ? Icons.paypal
                      : Icons.credit_card,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  _getPaymentMethodName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              _cardNumberController.text.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _formatCardNumber(_cardNumberController.text),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cardHolderController.text.isEmpty
                          ? 'YOUR NAME'
                          : _cardHolderController.text.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expiryController.text.isEmpty
                          ? 'MM/YY'
                          : _expiryController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'EGP ${widget.order.totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _getPaymentColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      maxLength: 19,
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        prefixIcon: Icon(Icons.credit_card, color: _getPaymentColor()),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getPaymentColor(), width: 2),
        ),
        counterText: '',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberFormatter(),
      ],
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.replaceAll(' ', '').length < 16) {
          return 'Invalid card number';
        }
        return null;
      },
    );
  }

  Widget _buildCardHolderField() {
    return TextFormField(
      controller: _cardHolderController,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Cardholder Name',
        hintText: 'JOHN DOE',
        prefixIcon: Icon(Icons.person_outline, color: _getPaymentColor()),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getPaymentColor(), width: 2),
        ),
      ),
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      keyboardType: TextInputType.number,
      maxLength: 5,
      decoration: InputDecoration(
        labelText: 'Expiry',
        hintText: 'MM/YY',
        prefixIcon: Icon(Icons.calendar_today, color: _getPaymentColor()),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getPaymentColor(), width: 2),
        ),
        counterText: '',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ExpiryDateFormatter(),
      ],
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.length < 5) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildCVVField() {
    return TextFormField(
      controller: _cvvController,
      keyboardType: TextInputType.number,
      maxLength: 3,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        prefixIcon: Icon(Icons.lock_outline, color: _getPaymentColor()),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getPaymentColor(), width: 2),
        ),
        counterText: '',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.length < 3) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPaymentColor(),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pay EGP ${widget.order.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(_getPaymentColor()),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Processing Payment...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 120,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your order has been confirmed',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}

// Card Number Formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry Date Formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
