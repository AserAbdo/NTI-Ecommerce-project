import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';

/// Data model for navigation items
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

/// Default navigation items for the app
class NavItems {
  static const List<NavItemData> items = [
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
}

/// Individual navigation item widget
class NavItem extends StatelessWidget {
  final NavItemData itemData;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
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
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 4 : 8,
              vertical: isSmall ? 4 : 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  isSelected ? itemData.activeIcon : itemData.icon,
                  color: isSelected ? AppColors.primary : inactiveColor,
                  size: isSmall ? 22 : 24,
                ),
                const SizedBox(height: 2),
                // Label with overflow handling
                Text(
                  itemData.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : inactiveColor,
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
