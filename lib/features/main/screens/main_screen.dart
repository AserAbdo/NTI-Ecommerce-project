import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../cart/cubits/cart_state.dart';
import '../../products/screens/home_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../profile/screens/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  late final List<Widget> _screens = const [
    HomeScreen(), // 0
    OrdersScreen(), // 1
    SizedBox(), // 2 (Cart handled by FAB)
    FavoritesScreen(), // 3
    AccountScreen(), // 4
  ];

  final List<NavItemData> _navItems = [
    NavItemData(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: AppStrings.home,
    ),
    NavItemData(
      icon: Icons.receipt_long_rounded,
      activeIcon: Icons.receipt_long,
      label: AppStrings.orders,
    ),
    NavItemData(
      icon: Icons.favorite_rounded,
      activeIcon: Icons.favorite,
      label: AppStrings.favourites,
    ),
    NavItemData(
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      label: AppStrings.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _currentIndex = index;
      });
    }
  }

  int _getIndexFromBottomNav(int tappedIndex) {
    if (tappedIndex == 0) return 0;
    if (tappedIndex == 1) return 1;
    if (tappedIndex == 2) return 3;
    if (tappedIndex == 3) return 4;
    return 0;
  }

  int _getBottomNavIndexFromScreen() {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 3) return 2;
    if (_currentIndex == 4) return 3;
    return 0;
  }

  Widget _buildChatFloatingButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(25),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF1E2746).withOpacity(0.4),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.mainChatBot);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 55,
            height: 55,
            padding: const EdgeInsets.all(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavIndex = _getBottomNavIndexFromScreen();
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          Positioned(
            bottom: 110,
            right: 20,
            child: _buildChatFloatingButton(context),
          ),
        ],
      ),
      extendBody: true,

      // Premium Floating Cart Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
        ),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            int count = 0;
            if (state is CartLoaded) {
              count = state.items.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
            }

            return GestureDetector(
              onTapDown: (_) {
                _fabAnimationController.reverse();
              },
              onTapUp: (_) {
                _fabAnimationController.forward();
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              onTapCancel: () {
                _fabAnimationController.forward();
              },
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 26,
                              minHeight: 26,
                            ),
                            child: Center(
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // Premium Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          elevation: 0,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
            height: 0,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedNavItem(
                        itemData: _navItems[0],
                        isSelected: bottomNavIndex == 0,
                        onTap: () => _onTap(_getIndexFromBottomNav(0)),
                      ),
                      _buildAnimatedNavItem(
                        itemData: _navItems[1],
                        isSelected: bottomNavIndex == 1,
                        onTap: () => _onTap(_getIndexFromBottomNav(1)),
                      ),
                    ],
                  ),
                ),

                // Spacer for center FAB
                const SizedBox(width: 80),

                // Right side
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedNavItem(
                        itemData: _navItems[2],
                        isSelected: bottomNavIndex == 2,
                        onTap: () => _onTap(_getIndexFromBottomNav(2)),
                      ),
                      _buildAnimatedNavItem(
                        itemData: _navItems[3],
                        isSelected: bottomNavIndex == 3,
                        onTap: () => _onTap(_getIndexFromBottomNav(3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required NavItemData itemData,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 + (value * 4),
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.12),
                  value,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle for selected state
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                        ),
                      ),
                      // Icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isSelected ? itemData.activeIcon : itemData.icon,
                          key: ValueKey(isSelected),
                          color: Color.lerp(
                            AppColors.textSecondary,
                            AppColors.primary,
                            value,
                          ),
                          size: 24 + (value * 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: Color.lerp(
                        AppColors.textSecondary,
                        AppColors.primary,
                        value,
                      ),
                      letterSpacing: isSelected ? 0.2 : 0,
                    ),
                    child: Text(itemData.label),
                  ),
                  // Active indicator dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(top: 2),
                    width: isSelected ? 4 : 0,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
