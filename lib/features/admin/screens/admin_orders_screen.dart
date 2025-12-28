import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';

/// Admin Orders Screen - Manages order listing and status updates
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'All';

  static const List<Map<String, dynamic>> _statuses = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': Colors.blue},
    {'name': 'pending', 'icon': Icons.schedule_rounded, 'color': Colors.orange},
    {
      'name': 'processing',
      'icon': Icons.autorenew_rounded,
      'color': Colors.blue,
    },
    {
      'name': 'shipped',
      'icon': Icons.local_shipping_rounded,
      'color': Colors.purple,
    },
    {
      'name': 'delivered',
      'icon': Icons.check_circle_rounded,
      'color': Colors.green,
    },
    {'name': 'cancelled', 'icon': Icons.cancel_rounded, 'color': Colors.red},
  ];

  void _onStatusFilterChanged(String status) {
    setState(() => _selectedStatus = status);
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await AdminController.updateOrderStatus(orderId, newStatus);

    if (mounted) {
      _showSuccessSnackBar('Order status updated to $newStatus');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildStatusFilterBar(isDark),
        const SizedBox(height: 16),
        Expanded(child: _buildOrdersList(isDark)),
      ],
    );
  }

  Widget _buildStatusFilterBar(bool isDark) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final isSelected = _selectedStatus == status['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: StatusFilterPill(
              name: status['name'] as String,
              icon: status['icon'] as IconData,
              color: status['color'] as Color,
              isSelected: isSelected,
              onTap: () => _onStatusFilterChanged(status['name'] as String),
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: AdminController.getOrdersStream(
        statusFilter: _selectedStatus == 'All' ? null : _selectedStatus,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AdminErrorState(
            error: snapshot.error.toString(),
            isDark: isDark,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return AdminEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No orders found',
            subtitle: 'Orders will appear here when customers place them',
            isDark: isDark,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data() as Map<String, dynamic>;

            return _OrderCard(
              orderId: doc.id,
              data: data,
              isDark: isDark,
              onStatusChanged: (newStatus) =>
                  _updateOrderStatus(doc.id, newStatus),
            );
          },
        );
      },
    );
  }
}

/// Order card widget for displaying individual orders
class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final bool isDark;
  final Function(String) onStatusChanged;

  const _OrderCard({
    required this.orderId,
    required this.data,
    required this.isDark,
    required this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'processing':
        return Icons.autorenew_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final total = (data['totalAmount'] ?? 0).toDouble();
    final items = (data['items'] as List?)?.length ?? 0;
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy • HH:mm').format(createdAt.toDate())
        : 'Unknown date';

    final customerName = _extractCustomerName(data);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: _buildStatusIcon(status),
          title: _buildOrderHeader(status),
          subtitle: _buildOrderSummary(customerName, total, items),
          children: [
            _buildOrderDetails(dateStr, data),
            const SizedBox(height: 16),
            _buildStatusDropdown(status),
          ],
        ),
      ),
    );
  }

  String _extractCustomerName(Map<String, dynamic> data) {
    try {
      final addressData = data['shippingAddress'];
      if (addressData is Map<String, dynamic>) {
        return addressData['name']?.toString() ?? 'Unknown customer';
      } else if (addressData is String) {
        return addressData;
      }
    } catch (e) {
      // Ignore errors
    }
    return 'Unknown customer';
  }

  Widget _buildStatusIcon(String status) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status),
        size: 26,
      ),
    );
  }

  Widget _buildOrderHeader(String status) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '#${orderId.substring(0, 8).toUpperCase()}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _getStatusColor(status),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(String customerName, double total, int items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EGP ${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '• $items items',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(String dateStr, Map<String, dynamic> data) {
    final shippingAddress = data['shippingAddress'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.calendar_today_rounded, 'Order Date', dateStr),
          if (shippingAddress is Map<String, dynamic> &&
              shippingAddress['address'] != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.location_on_rounded,
              'Address',
              '${shippingAddress['address'] ?? ''}'
                  '${shippingAddress['city'] != null ? ', ${shippingAddress['city']}' : ''}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(String currentStatus) {
    return Row(
      children: [
        Text(
          'Update Status:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentStatus,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                dropdownColor: isDark ? const Color(0xFF2D2D3F) : Colors.white,
                items:
                    [
                          'pending',
                          'processing',
                          'shipped',
                          'delivered',
                          'cancelled',
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(s),
                                  size: 18,
                                  color: _getStatusColor(s),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  s.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(s),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != currentStatus) {
                    onStatusChanged(newStatus);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
