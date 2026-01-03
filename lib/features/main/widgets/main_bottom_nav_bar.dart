import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import 'nav_item.dart';

/// Custom bottom navigation bar with notch for cart FAB
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisible;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: SafeArea(
          top: false,
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
              child: SizedBox(
                height: isSmall ? 50 : 60,
                child: Row(
                  children: [
                    // Left side: Home
                    Expanded(
                      child: NavItem(
                        itemData: NavItems.items[0],
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                    // Left side: Orders
                    Expanded(
                      child: NavItem(
                        itemData: NavItems.items[1],
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                    // Center spacer for FAB
                    SizedBox(width: isSmall ? 56 : 72),
                    // Right side: Favorites
                    Expanded(
                      child: NavItem(
                        itemData: NavItems.items[2],
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                    // Right side: Profile
                    Expanded(
                      child: NavItem(
                        itemData: NavItems.items[3],
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
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
