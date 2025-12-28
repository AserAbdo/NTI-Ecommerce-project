import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
              color: _selectedIndex == 0 ? AppColors.primary : Colors.grey,
            ),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: _selectedIndex == 1 ? AppColors.primary : Colors.grey,
            ),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
