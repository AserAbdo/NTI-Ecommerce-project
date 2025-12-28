import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';

/// Admin Dashboard Screen - Main entry point for admin panel
/// Uses clean architecture with separated controller & widgets
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = const [
    AdminProductsScreen(),
    AdminOrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF8FAFF), const Color(0xFFE8F0FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStatisticsGrid(isDark),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTabBar(isDark),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 16),
          Expanded(child: _buildTitleSection(isDark)),
          _buildLogoutButton(isDark),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Manage your store',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.logout_rounded,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
        onPressed: _logout,
      ),
    );
  }

  Widget _buildStatisticsGrid(bool isDark) {
    return StreamBuilder<AdminStats>(
      stream: AdminController.getStatsStream(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? AdminStats.empty();

        return Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Revenue',
                value: 'EGP ${stats.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.trending_up_rounded,
                gradientColors: const [Color(0xFF00B894), Color(0xFF00CEC9)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Orders',
                value: stats.totalOrders.toString(),
                icon: Icons.shopping_bag_rounded,
                gradientColors: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Products',
                value: stats.totalProducts.toString(),
                icon: Icons.inventory_2_rounded,
                gradientColors: const [Color(0xFFE17055), Color(0xFFFAB1A0)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Pending',
                value: stats.pendingOrders.toString(),
                icon: Icons.pending_actions_rounded,
                gradientColors: const [Color(0xFFE84393), Color(0xFFFD79A8)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AdminTabButton(
              label: 'Products',
              icon: Icons.inventory_2_rounded,
              isSelected: _selectedIndex == 0,
              onTap: () => _onTabSelected(0),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AdminTabButton(
              label: 'Orders',
              icon: Icons.receipt_long_rounded,
              isSelected: _selectedIndex == 1,
              onTap: () => _onTabSelected(1),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_selectedIndex),
        child: _screens[_selectedIndex],
      ),
    );
  }
}
