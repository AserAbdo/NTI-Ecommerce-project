import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Logo widget for auth screens
class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Icon(
        Icons.shopping_bag_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
