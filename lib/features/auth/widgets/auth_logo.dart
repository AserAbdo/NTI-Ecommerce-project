import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Logo widget for auth screens
class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
