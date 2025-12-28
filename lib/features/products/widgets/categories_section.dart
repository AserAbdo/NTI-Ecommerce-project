import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

/// Horizontal scrollable category chips
class CategoriesSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoriesSection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Electronics', 'icon': Icons.devices_rounded},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'name': 'Home', 'icon': Icons.home_rounded},
    {'name': 'Beauty', 'icon': Icons.face_rounded},
    {'name': 'Groceries', 'icon': Icons.shopping_basket_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isSmallMobile(context) ? 45 : 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context),
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CategoryChip(
              name: category['name'],
              icon: category['icon'],
              isSelected: isSelected,
              onTap: () => onCategorySelected(category['name']),
            ),
          );
        },
      ),
    );
  }
}

/// Individual category chip
class _CategoryChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isSmallMobile(context) ? 14 : 16,
          vertical: ResponsiveHelper.isSmallMobile(context) ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.isSmallMobile(context) ? 16 : 18,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: ResponsiveHelper.isSmallMobile(context) ? 13 : 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
