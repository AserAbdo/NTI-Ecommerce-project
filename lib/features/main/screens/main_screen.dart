import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../cart/cubits/cart_cubit.dart';
import '../../cart/cubits/cart_state.dart';
import '../../products/screens/home_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../profile/screens/account_screen.dart';
import '../controllers/scroll_visibility_controller.dart';

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

  final List<NavItemData> _navItems = const [
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
    // Trigger rebuild only for navbar visibility
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.removeListener(_onScrollVisibilityChanged);
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      // Reset navbar visibility when switching tabs
      _scrollController.reset();
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

  @override
  Widget build(BuildContext context) {
    final bottomNavIndex = _getBottomNavIndexFromScreen();
    final isNavbarVisible = _scrollController.isNavbarVisible;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // Chat floating button
          Positioned(
            bottom: ResponsiveHelper.isSmallMobile(context) ? 90 : 100,
            right: ResponsiveHelper.isSmallMobile(context) ? 12 : 20,
            child: _ChatFloatingButton(),
          ),
        ],
      ),
      extendBody: true,

      // Premium Floating Cart Button - Always visible
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CartFAB(
        fabAnimationController: _fabAnimationController,
      ),

      // Animated Bottom Navigation Bar
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: isNavbarVisible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isNavbarVisible ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                height: ResponsiveHelper.isSmallMobile(context) ? 60 : 70,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isSmallMobile(context) ? 4 : 8,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _NavItem(
                            itemData: _navItems[0],
                            isSelected: bottomNavIndex == 0,
                            onTap: () => _onTap(_getIndexFromBottomNav(0)),
                          ),
                          _NavItem(
                            itemData: _navItems[1],
                            isSelected: bottomNavIndex == 1,
                            onTap: () => _onTap(_getIndexFromBottomNav(1)),
                          ),
                        ],
                      ),
                    ),

                    // Spacer for center FAB
                    SizedBox(
                      width: ResponsiveHelper.isSmallMobile(context) ? 100 : 80,
                    ),

                    // Right side
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _NavItem(
                            itemData: _navItems[2],
                            isSelected: bottomNavIndex == 2,
                            onTap: () => _onTap(_getIndexFromBottomNav(2)),
                          ),
                          _NavItem(
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
        ),
      ),
    );
  }
}

/// Chat floating button - Extracted as separate widget to prevent rebuilds
class _ChatFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(25),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF1E2746).withValues(alpha: 0.4),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.mainChatBot);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: ResponsiveHelper.isSmallMobile(context) ? 48 : 55,
            height: ResponsiveHelper.isSmallMobile(context) ? 48 : 55,
            padding: EdgeInsets.all(
              ResponsiveHelper.isSmallMobile(context) ? 10 : 12,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: ResponsiveHelper.isSmallMobile(context) ? 24 : 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cart FAB - Extracted as separate widget with optimized BlocBuilder
class _CartFAB extends StatelessWidget {
  final AnimationController fabAnimationController;

  const _CartFAB({required this.fabAnimationController});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: fabAnimationController,
        curve: Curves.elasticOut,
      ),
      // Use buildWhen to only rebuild when cart items change
      child: BlocSelector<CartCubit, CartState, int>(
        selector: (state) {
          if (state is CartLoaded) {
            return state.items.fold<int>(0, (sum, item) => sum + item.quantity);
          }
          return 0;
        },
        builder: (context, count) {
          return _CartButton(
            count: count,
            animationController: fabAnimationController,
          );
        },
      ),
    );
  }
}

/// Cart button inner widget
class _CartButton extends StatelessWidget {
  final int count;
  final AnimationController animationController;

  const _CartButton({required this.count, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => animationController.reverse(),
      onTapUp: (_) {
        animationController.forward();
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, AppRoutes.cart);
      },
      onTapCancel: () => animationController.forward(),
      child: Container(
        height: ResponsiveHelper.isSmallMobile(context) ? 60 : 68,
        width: ResponsiveHelper.isSmallMobile(context) ? 60 : 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
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
                size: ResponsiveHelper.isSmallMobile(context) ? 26 : 30,
              ),
            ),
            if (count > 0) _CartBadge(count: count),
          ],
        ),
      ),
    );
  }
}

/// Cart badge - Separated for animation optimization
class _CartBadge extends StatelessWidget {
  final int count;

  const _CartBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
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
    );
  }
}

/// Navigation item - Optimized with const constructor and RepaintBoundary
class _NavItem extends StatelessWidget {
  final NavItemData itemData;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.itemData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textSecondary;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isSmallMobile(context)
                  ? (isSelected ? 10 : 8)
                  : (isSelected ? 16 : 12),
              vertical: ResponsiveHelper.isSmallMobile(context) ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: ResponsiveHelper.isSmallMobile(context) ? 36 : 40,
                  height: ResponsiveHelper.isSmallMobile(context) ? 36 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    isSelected ? itemData.activeIcon : itemData.icon,
                    color: isSelected ? AppColors.primary : inactiveColor,
                    size: ResponsiveHelper.isSmallMobile(context)
                        ? (isSelected ? 22 : 20)
                        : (isSelected ? 26 : 24),
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                Text(
                  itemData.label,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isSmallMobile(context) ? 10 : 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : inactiveColor,
                    letterSpacing: isSelected ? 0.2 : 0,
                  ),
                ),
                // Active indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
      ),
    );
  }
}

/// Nav item data - Made immutable with const constructor
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
