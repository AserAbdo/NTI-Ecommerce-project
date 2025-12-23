import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'All', 'icon': Icons.list_alt},
    {'id': 'pending', 'label': 'Pending', 'icon': Icons.pending_outlined},
    {
      'id': 'confirmed',
      'label': 'Confirmed',
      'icon': Icons.check_circle_outline,
    },
    {'id': 'delivered', 'label': 'Delivered', 'icon': Icons.done_all},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFilter = _filters[_tabController.index]['id'];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myOrders),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('Please login to view orders')),
      );
    }

    final userId = authState.user.id;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppStrings.myOrders,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: _filters.map((filter) {
                return Tab(
                  child: Row(
                    children: [
                      Icon(filter['icon'], size: 18),
                      const SizedBox(width: 6),
                      Text(filter['label']),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getOrdersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              title: _selectedFilter == 'all'
                  ? AppStrings.noOrders
                  : 'No ${_selectedFilter} orders',
              message: _selectedFilter == 'all'
                  ? 'Start shopping to see your orders here'
                  : null,
              icon: Icons.receipt_long_outlined,
              action: null,
            );
          }

          final orders = snapshot.data!.docs;

          return Column(
            children: [
              // Stats Summary
              _buildStatsSummary(orders),

              // Orders List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getHorizontalPadding(context),
                    ),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final orderData =
                          orders[index].data() as Map<String, dynamic>;
                      final order = OrderModel.fromJson(orderData);
                      return OrderCard(order: order);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getOrdersStream(String userId) {
    // Simple query without composite index requirement
    if (_selectedFilter == 'all') {
      // For "All" tab: just filter by userId and sort by createdAt
      return FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      // For filtered tabs: filter by userId and status (no orderBy to avoid composite index)
      return FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: _selectedFilter)
          .snapshots();
    }
  }

  Widget _buildStatsSummary(List<QueryDocumentSnapshot> orders) {
    double totalSpent = 0;
    int totalItems = 0;

    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      totalSpent += (data['totalPrice'] ?? 0.0) as double;
      totalItems += (data['items'] as List?)?.length ?? 0;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Orders',
              value: '${orders.length}',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              icon: Icons.inventory_2_outlined,
              label: 'Items',
              value: '$totalItems',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              icon: Icons.payments_outlined,
              label: 'Spent',
              value: 'EGP ${totalSpent.toStringAsFixed(0)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
