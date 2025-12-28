import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';

/// Greeting section with user name and welcome message
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final userName = state is AuthAuthenticated
            ? state.user.name.split(' ').first
            : 'Guest';

        return Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Text(
                'Hello, $userName! 👋',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isSmallMobile(context) ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: ResponsiveHelper.isSmallMobile(context) ? 4 : 8),

              // Subtitle
              Text(
                'What are you looking for today?',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isSmallMobile(context) ? 14 : 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
