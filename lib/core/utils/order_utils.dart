import 'package:flutter/material.dart';

class OrderUtils {
  // Generate unique order number in format: ORD-YYYY-NNNNNN
  static String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year;
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 1000000; // Last 6 digits
    return 'ORD-$year-${random.toString().padLeft(6, '0')}';
  }

  // Calculate 10% tax
  static double calculateTax(double subtotal) {
    return subtotal * 0.10;
  }

  // Calculate shipping fee (fixed EGP 100 for now)
  static double calculateShippingFee({String? city}) {
    // Could be dynamic based on city in the future
    return 100.0;
  }

  // Apply discount (placeholder for future coupon system)
  static double applyDiscount(double subtotal, {String? couponCode}) {
    // Future: implement coupon validation
    if (couponCode != null && couponCode.isNotEmpty) {
      // Example: 10% discount for demo
      return subtotal * 0.10;
    }
    return 0.0;
  }

  // Format order date nicely
  static String formatOrderDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  // Format full date and time
  static String formatFullDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${_monthName(date.month)} ${date.day}, ${date.year} • ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  // Get estimated delivery date (5-7 days from order)
  static DateTime getEstimatedDeliveryDate(DateTime orderDate) {
    return orderDate.add(const Duration(days: 6));
  }

  // Get order status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get order status icon
  static IconData getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // Get payment status color
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Generate mock tracking updates
  static List<Map<String, dynamic>> getMockTrackingUpdates(
    String orderNumber,
    String status,
    DateTime createdAt,
  ) {
    final updates = <Map<String, dynamic>>[];

    // Order placed
    updates.add({
      'title': 'Order Placed',
      'description': 'Your order has been received',
      'timestamp': createdAt,
      'completed': true,
    });

    // Payment confirmed
    updates.add({
      'title': 'Payment Confirmed',
      'description': 'Payment has been verified',
      'timestamp': createdAt.add(const Duration(minutes: 1)),
      'completed': true,
    });

    // Processing
    final processingDate = createdAt.add(const Duration(hours: 1));
    updates.add({
      'title': 'Processing',
      'description': 'Your order is being prepared',
      'timestamp': processingDate,
      'completed': [
        'processing',
        'shipped',
        'delivered',
      ].contains(status.toLowerCase()),
    });

    // Shipped
    final shippedDate = createdAt.add(const Duration(days: 1));
    updates.add({
      'title': 'Shipped',
      'description': 'Your order is on the way',
      'timestamp': shippedDate,
      'completed': ['shipped', 'delivered'].contains(status.toLowerCase()),
    });

    // Out for delivery
    final outForDeliveryDate = createdAt.add(const Duration(days: 5));
    updates.add({
      'title': 'Out for Delivery',
      'description': 'Order is out for delivery',
      'timestamp': outForDeliveryDate,
      'completed': status.toLowerCase() == 'delivered',
    });

    // Delivered
    final deliveredDate = createdAt.add(const Duration(days: 6));
    updates.add({
      'title': 'Delivered',
      'description': 'Order has been delivered',
      'timestamp': deliveredDate,
      'completed': status.toLowerCase() == 'delivered',
    });

    return updates;
  }

  // Generate tracking number
  static String generateTrackingNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 1000000;
    return 'TRK-${DateTime.now().year}-${random.toString().padLeft(6, '0')}';
  }

  // Validate phone number (Egyptian format)
  static bool isValidPhone(String phone) {
    // Remove spaces and special characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Check if it's a valid Egyptian number
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  // Validate postal code
  static bool isValidPostalCode(String postalCode) {
    return postalCode.length >= 4 && postalCode.length <= 10;
  }
}
