import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../services/seed_service.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/theme_toggle_item.dart';
import '../models/menu_item_data.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return _buildUnauthenticatedView(context);
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: ProfileHeader(
                userName: user.name,
                userEmail: user.email,
                fadeAnimation: _fadeAnimation,
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Stats Cards
                    _buildStatsSection(context),

                    const SizedBox(height: 24),

                    // Personal Information Section
                    _buildPersonalInfoSection(context, user),

                    const SizedBox(height: 24),

                    // Account Settings Section
                    _buildAccountSettingsSection(context),

                    const SizedBox(height: 24),

                    // App Settings Section
                    _buildAppSettingsSection(context),

                    const SizedBox(height: 24),

                    // Developer Tools Section (for seeding)
                    _buildDevToolsSection(context),

                    const SizedBox(height: 24),

                    // Support Section
                    _buildSupportSection(context),

                    const SizedBox(height: 24),

                    // Logout Button
                    const ProfileLogoutButton(),

                    // Extra padding for bottom nav bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Please Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Access your account to view profile',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Login Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: Row(
        children: const [
          Expanded(
            child: ProfileStatCard(
              icon: Icons.shopping_bag_outlined,
              label: 'Orders',
              value: '12',
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.favorite_outline,
              label: 'Favorites',
              value: '8',
              color: Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.local_offer_outlined,
              label: 'Coupons',
              value: '1',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, user) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: ProfileSectionCard(
        title: AppStrings.personalInfo,
        icon: Icons.person_outline,
        children: [
          ProfileInfoTile(
            icon: Icons.person_outline,
            label: 'Name',
            value: user.name,
          ),
          ProfileInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          ProfileInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone.isNotEmpty ? user.phone : 'Not provided',
          ),
          ProfileInfoTile(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: user.address ?? 'Not provided',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    final items = [
      MenuItemData(
        icon: Icons.edit_outlined,
        title: 'Edit Profile',
        subtitle: 'Update your information',
        color: Colors.blue,
      ),
      MenuItemData(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password',
        color: Colors.orange,
      ),
      MenuItemData(
        icon: Icons.credit_card_outlined,
        title: 'Payment Methods',
        subtitle: 'Manage payment cards',
        color: Colors.green,
      ),
      MenuItemData(
        icon: Icons.location_city_outlined,
        title: 'Addresses',
        subtitle: 'Manage shipping addresses',
        color: Colors.purple,
        isLast: true,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: ProfileSectionCard(
        title: 'Account Settings',
        icon: Icons.settings_outlined,
        children: items
            .map(
              (item) => ProfileMenuItem(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                color: item.color,
                isLast: item.isLast,
                onTap: () => _showComingSoonSnackBar(context, item.title),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: ProfileSectionCard(
        title: 'Preferences',
        icon: Icons.tune_outlined,
        children: [
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notifications',
            color: Colors.red,
            onTap: () => _showComingSoonSnackBar(context, 'Notifications'),
          ),
          ProfileMenuItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English (US)',
            color: Colors.blue,
            onTap: () => _showComingSoonSnackBar(context, 'Language'),
          ),
          const ThemeToggleItem(),
          ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Security',
            subtitle: 'Control your privacy',
            color: Colors.teal,
            isLast: true,
            onTap: () => _showComingSoonSnackBar(context, 'Privacy & Security'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final items = [
      MenuItemData(
        icon: Icons.help_center_outlined,
        title: 'Help Center',
        subtitle: 'Get help and FAQs',
        color: Colors.cyan,
      ),
      MenuItemData(
        icon: Icons.chat_bubble_outline,
        title: 'Contact Us',
        subtitle: 'Chat with support',
        color: Colors.green,
      ),
      MenuItemData(
        icon: Icons.star_outline,
        title: 'Rate App',
        subtitle: 'Share your feedback',
        color: Colors.amber,
      ),
      MenuItemData(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Version 1.0.0',
        color: Colors.grey,
      ),
      MenuItemData(
        icon: Icons.policy_outlined,
        title: 'Privacy Policy',
        subtitle: 'Terms and conditions',
        color: Colors.blueGrey,
        isLast: true,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: ProfileSectionCard(
        title: 'Support & Legal',
        icon: Icons.help_outline,
        children: items
            .map(
              (item) => ProfileMenuItem(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                color: item.color,
                isLast: item.isLast,
                onTap: () => _showComingSoonSnackBar(context, item.title),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDevToolsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
      ),
      child: ProfileSectionCard(
        title: 'Developer Tools',
        icon: Icons.developer_mode,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSeeding ? null : () => _seedDatabase(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: _isSeeding
                    ? _buildSeedingShimmer(isDark)
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_rounded,
                              color: Colors.green,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seed Database',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Upload sample products to Firestore',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedingShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDatabase(BuildContext context) async {
    setState(() => _isSeeding = true);

    try {
      await SeedService.seedProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Database seeded successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }
}
