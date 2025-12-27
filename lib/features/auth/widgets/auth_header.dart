import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.w800,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: ResponsiveHelper.isSmallMobile(context) ? 8 : 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
