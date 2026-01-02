import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Gradient background container for auth screens
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                  AppColors.primary.withValues(alpha: 0.7),
                ],
        ),
      ),
      child: child,
    );
  }
}
