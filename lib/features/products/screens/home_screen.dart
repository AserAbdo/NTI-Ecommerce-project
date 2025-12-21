import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../services/seed_service.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            iconSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            iconSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getHorizontalPadding(context) * 0.66,
                  ),
                  color: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    'Welcome, ${state.user.name}!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getHorizontalPadding(
                          context,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: ResponsiveHelper.getIconSize(context),
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getSpacing(context, 16),
                          ),
                          Text(
                            'Products Coming Soon!',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.getSubtitleFontSize(
                                    context,
                                  ) +
                                  4,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getSpacing(context, 8),
                          ),
                          Text(
                            'We are working on adding products',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getBodyFontSize(
                                context,
                              ),
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getSpacing(context, 24),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Check if products already exist
                              final isEmpty =
                                  await SeedService.isProductsEmpty();
                              if (isEmpty) {
                                await SeedService.seedProducts();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Products seeded successfully!',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '⚠️ Products already exist!',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: Text(
                              'Seed Products (Dev Only)',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getBodyFontSize(
                                  context,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(
                                  context,
                                  24,
                                ),
                                vertical: ResponsiveHelper.getSpacing(
                                  context,
                                  12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getSpacing(context, 16),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getBodyFontSize(
                                  context,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(
                                  context,
                                  24,
                                ),
                                vertical: ResponsiveHelper.getSpacing(
                                  context,
                                  12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
