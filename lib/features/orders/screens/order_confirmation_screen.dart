import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/order_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({Key? key, required this.order})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.orderConfirmation),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: ResponsiveHelper.getIconSize(context),
              color: Colors.green,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
            Text(
              AppStrings.thankYou,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),
            Text(
              AppStrings.orderPlaced,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(label: AppStrings.orderId, value: order.orderId),
                  const SizedBox(height: 8),
                  _InfoRow(label: AppStrings.items, value: '$itemCount'),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: AppStrings.total,
                    value:
                        '${order.totalPrice.toStringAsFixed(0)} ${AppStrings.egp}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: AppStrings.status, value: order.status),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, 32)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: Text(AppStrings.backToHome),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
