import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../widgets/info_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myAccount),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('Please login')),
      );
    }
    final user = authState.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAccount),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple row under AppBar with user name only
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Text(
              user.name,
              style: TextStyle(
                fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                ResponsiveHelper.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.personalInfo,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.person_outline,
                    label: 'Name',
                    value: user.name,
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user.phone.isNotEmpty ? user.phone : '-',
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: user.address ?? 'Not provided',
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(AppStrings.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  const AccountScreen({Key? key}) : super(key: key);
}
