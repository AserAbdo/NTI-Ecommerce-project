/// Admin order status configuration
class OrderStatusConfig {
  final String name;
  final String icon;
  final int colorValue;

  const OrderStatusConfig({
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  static const List<Map<String, dynamic>> allStatuses = [
    {'name': 'All', 'icon': 'apps_rounded', 'color': 0xFF2196F3},
    {'name': 'pending', 'icon': 'schedule_rounded', 'color': 0xFFFF9800},
    {'name': 'processing', 'icon': 'autorenew_rounded', 'color': 0xFF2196F3},
    {'name': 'shipped', 'icon': 'local_shipping_rounded', 'color': 0xFF9C27B0},
    {'name': 'delivered', 'icon': 'check_circle_rounded', 'color': 0xFF4CAF50},
    {'name': 'cancelled', 'icon': 'cancel_rounded', 'color': 0xFFF44336},
  ];

  static const List<String> orderStatuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  static int getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFF9800;
      case 'processing':
        return 0xFF2196F3;
      case 'shipped':
        return 0xFF9C27B0;
      case 'delivered':
        return 0xFF4CAF50;
      case 'cancelled':
        return 0xFFF44336;
      default:
        return 0xFF9E9E9E;
    }
  }
}

/// Product categories configuration
class ProductCategoryConfig {
  static const List<String> categories = [
    'Electronics',
    'Fashion',
    'Home',
    'Beauty',
    'Grocery',
  ];

  static String getIconName(String category) {
    switch (category) {
      case 'Electronics':
        return 'devices_rounded';
      case 'Fashion':
        return 'checkroom_rounded';
      case 'Home':
        return 'home_rounded';
      case 'Beauty':
        return 'spa_rounded';
      case 'Grocery':
        return 'shopping_basket_rounded';
      default:
        return 'category_rounded';
    }
  }
}
