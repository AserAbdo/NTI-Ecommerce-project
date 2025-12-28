import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../products/screens/home_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../profile/screens/account_screen.dart';
import '../controllers/scroll_visibility_controller.dart';
import '../widgets/widgets.dart';

/// Main screen with bottom navigation and floating action buttons
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  final ScrollVisibilityController _scrollController =
      ScrollVisibilityController();

  // Cache screens to prevent rebuilds
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(), // 0
      const OrdersScreen(), // 1
      const SizedBox(), // 2 (Cart handled by FAB)
      FavoritesScreen(), // 3
      AccountScreen(), // 4
    ];

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    // Listen to scroll visibility changes
    _scrollController.addListener(_onScrollVisibilityChanged);
  }

  void _onScrollVisibilityChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.removeListener(_onScrollVisibilityChanged);
    super.dispose();
  }

  void _onNavTap(int bottomNavIndex) {
    final screenIndex = _getScreenIndexFromBottomNav(bottomNavIndex);
    if (_currentIndex != screenIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = screenIndex;
      });
      // Reset navbar visibility when switching tabs
      _scrollController.reset();
    }
  }

  int _getScreenIndexFromBottomNav(int bottomNavIndex) {
    // Map bottom nav indices to screen indices
    // 0 -> Home (0)
    // 1 -> Orders (1)
    // 2 -> Favorites (3) - skipping 2 which is cart
    // 3 -> Profile (4)
    const mapping = [0, 1, 3, 4];
    return mapping[bottomNavIndex];
  }

  int _getBottomNavIndexFromScreen() {
    // Reverse mapping
    switch (_currentIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Orders
      case 3:
        return 2; // Favorites
      case 4:
        return 3; // Profile
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavIndex = _getBottomNavIndexFromScreen();
    final isNavbarHidden = !_scrollController.isNavbarVisible;
    final navbarHeight = ResponsiveHelper.isSmallMobile(context) ? 60.0 : 70.0;

    return Scaffold(
      body: Stack(
        children: [
          // Main content screens
          IndexedStack(index: _currentIndex, children: _screens),

          // Chat floating button - positioned at bottom right
          Positioned(
            bottom: ResponsiveHelper.isSmallMobile(context) ? 20 : 30,
            right: ResponsiveHelper.isSmallMobile(context) ? 12 : 20,
            child: ChatFloatingButton(
              isNavbarHidden: isNavbarHidden,
              navbarHeight: navbarHeight,
            ),
          ),
        ],
      ),
      extendBody: true,

      // Floating Cart Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CartFloatingButton(
        animationController: _fabAnimationController,
        isNavbarHidden: isNavbarHidden,
        navbarHeight: navbarHeight,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: bottomNavIndex,
        onTap: _onNavTap,
        isVisible: _scrollController.isNavbarVisible,
      ),
    );
  }
}
