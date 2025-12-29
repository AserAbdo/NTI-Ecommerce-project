import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(authState.user.id)
            .collection('payment_methods')
            .orderBy('isDefault', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saved Cards Section Header
                Text(
                  'Saved Cards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Methods List
                if (cards.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ...cards.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _PaymentCard(
                      id: doc.id,
                      data: data,
                      userId: authState.user.id,
                      isDark: isDark,
                    );
                  }),

                const SizedBox(height: 24),

                // Add New Card Button
                _buildAddCardButton(context, authState.user.id, isDark),

                const SizedBox(height: 24),

                // Other Payment Options
                Text(
                  'Other Payment Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  'Cash on Delivery',
                  'Pay when you receive your order',
                  Icons.payments_rounded,
                  Colors.green,
                  isDark,
                ),
                _buildPaymentOption(
                  'Mobile Wallet',
                  'Vodafone Cash, Orange Money, etc.',
                  Icons.phone_android_rounded,
                  Colors.orange,
                  isDark,
                ),
                _buildPaymentOption(
                  'Bank Transfer',
                  'Direct bank transfer',
                  Icons.account_balance_rounded,
                  Colors.blue,
                  isDark,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_off_rounded,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No saved cards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a card for faster checkout',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context, String userId, bool isDark) {
    return GestureDetector(
      onTap: () => _showAddCardDialog(context, userId),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_card_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Add New Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, String userId) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    bool isDefault = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.credit_card_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Add New Card',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                height: 1,
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Card Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.primary.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.credit_card_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                Text(
                                  'VISA',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Text(
                              cardNumberController.text.isEmpty
                                  ? '•••• •••• •••• ••••'
                                  : _formatCardNumber(
                                      cardNumberController.text,
                                    ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CARD HOLDER',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      nameController.text.isEmpty
                                          ? 'YOUR NAME'
                                          : nameController.text.toUpperCase(),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expiryController.text.isEmpty
                                          ? 'MM/YY'
                                          : expiryController.text,
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

                      const SizedBox(height: 24),

                      _buildTextField(
                        'Card Number',
                        cardNumberController,
                        Icons.credit_card_rounded,
                        isDark,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Cardholder Name',
                        nameController,
                        Icons.person_rounded,
                        isDark,
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Expiry (MM/YY)',
                              expiryController,
                              Icons.calendar_today_rounded,
                              isDark,
                              onChanged: (_) => setModalState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'CVV',
                              cvvController,
                              Icons.lock_rounded,
                              isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Default checkbox
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isDefault,
                              onChanged: (value) => setModalState(
                                () => isDefault = value ?? false,
                              ),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Set as default payment method',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            final lastFour =
                                cardNumberController.text.length >= 4
                                ? cardNumberController.text.substring(
                                    cardNumberController.text.length - 4,
                                  )
                                : '****';

                            final cardData = {
                              'lastFour': lastFour,
                              'cardHolder': nameController.text.trim(),
                              'expiry': expiryController.text.trim(),
                              'isDefault': isDefault,
                              'cardType': 'Visa',
                              'createdAt': FieldValue.serverTimestamp(),
                            };

                            final collection = FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('payment_methods');

                            if (isDefault) {
                              final batch = FirebaseFirestore.instance.batch();
                              final existingDefaults = await collection
                                  .where('isDefault', isEqualTo: true)
                                  .get();
                              for (var doc in existingDefaults.docs) {
                                batch.update(doc.reference, {
                                  'isDefault': false,
                                });
                              }
                              await batch.commit();
                            }

                            await collection.add(cardData);

                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text('Card added successfully'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3D3D3D) : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final String userId;
  final bool isDark;

  const _PaymentCard({
    required this.id,
    required this.data,
    required this.userId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final lastFour = data['lastFour'] ?? '****';
    final cardHolder = data['cardHolder'] ?? '';
    final expiry = data['expiry'] ?? '';
    final isDefault = data['isDefault'] ?? false;
    final cardType = data['cardType'] ?? 'Visa';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cardType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  onPressed: () => _deleteCard(context),
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '•••• •••• •••• $lastFour',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cardHolder.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  expiry,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCard(BuildContext context) async {
    final dialogIsDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogIsDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Remove Card?',
              style: TextStyle(
                color: dialogIsDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'This card will be removed from your account.',
          style: TextStyle(
            color: dialogIsDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dialogIsDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .doc(id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Card removed'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
