import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/widgets/snow_effect.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../../coupons/models/coupon_model.dart';
import '../../coupons/services/coupon_service.dart';
import '../../search/cubits/search_cubit.dart';
import '../../search/screens/search_page.dart';

/// Custom AppBar for Home Screen with winter snow effect
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final userId = isAuthenticated ? authState.user.id : null;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E3A5F) : AppColors.primary,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: Stack(
          children: [
            // Snow effect background
            Positioned.fill(
              child: SnowEffect(
                snowflakeCount: 30,
                snowColor: Colors.white.withValues(alpha: 0.9),
                maxRadius: 3.5,
                minRadius: 1.0,
              ),
            ),
          ],
        ),
      ),
      title: const Text(
        'Vendora',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // Search Icon
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => SearchCubit(),
                  child: const SearchPage(),
                ),
              ),
            );
          },
        ),

        // Notification Icon with Coupon - shows badge based on active coupons
        if (isAuthenticated && userId != null)
          StreamBuilder<int>(
            stream: CouponService.getActiveCouponsCountStream(userId),
            builder: (context, snapshot) {
              final activeCoupons = snapshot.data ?? 0;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    if (activeCoupons > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showNotificationsSheet(context, userId),
              );
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _showNotificationsSheet(context, null),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context, String? userId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: userId != null
                  ? _buildCouponsList(context, userId, isDark)
                  : _buildLoginPrompt(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Login to see notifications',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(BuildContext context, String userId, bool isDark) {
    return StreamBuilder<List<CouponModel>>(
      stream: CouponService.getUserCouponsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final coupons = snapshot.data ?? [];

        if (coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            return _buildCouponNotification(context, coupons[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildCouponNotification(
    BuildContext context,
    CouponModel coupon,
    bool isDark,
  ) {
    final isActive = coupon.isValid;
    final isUsed = coupon.isUsed;
    final isExpired = coupon.isExpired;

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String subtitle;

    if (isUsed) {
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'USED';
      subtitle = 'This coupon has been used';
    } else if (isExpired) {
      statusColor = Colors.red;
      statusIcon = Icons.error_rounded;
      statusText = 'EXPIRED';
      subtitle = 'This coupon has expired';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.local_offer_rounded;
      statusText = 'ACTIVE';
      subtitle = 'Use this coupon at checkout';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isActive
            ? null
            : (isDark ? const Color(0xFF252536) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '🎉 ${coupon.discountPercentage.toInt()}% OFF Coupon',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey[400]
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: coupon.code));
                Navigator.pop(context);
                AppSnackBar.showSuccess(
                  context,
                  'Coupon "${coupon.code.toUpperCase()}" copied!',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon.code.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.copy_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Tap to copy • Valid for first order',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
