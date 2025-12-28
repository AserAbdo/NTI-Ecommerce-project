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
