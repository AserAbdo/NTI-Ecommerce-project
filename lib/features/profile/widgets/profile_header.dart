import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/snow_effect.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final Animation<double> fadeAnimation;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.fadeAnimation,
  });

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
                  const Color(0xFF1E3A5F),
                  const Color(0xFF2D5A7B),
                  const Color(0xFF1E3A5F),
                ]
              : [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                  AppColors.primary,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Snow effect
          const Positioned.fill(
            child: SnowEffect(
              snowflakeCount: 35,
              snowColor: Colors.white,
              maxRadius: 3.0,
              minRadius: 1.0,
            ),
          ),

          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content - Centered properly, below app bar
          Positioned.fill(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate if we need to scale down
                    final availableHeight = constraints.maxHeight;
                    final isCompact = availableHeight < 220;
                    final avatarSize = isCompact ? 70.0 : 80.0;
                    final outerRingSize = isCompact ? 90.0 : 110.0;
                    final middleRingSize = isCompact ? 82.0 : 100.0;
                    final titleFontSize = isCompact ? 18.0 : 22.0;
                    final spacing = isCompact ? 8.0 : 16.0;

                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: availableHeight),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Enhanced Profile Avatar
                              _buildAvatarResponsive(
                                avatarSize,
                                outerRingSize,
                                middleRingSize,
                              ),

                              SizedBox(height: spacing),

                              // User Name with verified badge - Fixed overflow
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: isCompact ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: spacing * 0.75),

                              // Member badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 10 : 12,
                                  vertical: isCompact ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.amber.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Colors.white,
                                      size: isCompact ? 12 : 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium Member',
                                      style: TextStyle(
                                        fontSize: isCompact ? 10 : 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarResponsive(
    double avatarSize,
    double outerRingSize,
    double middleRingSize,
  ) {
    final fontSize = avatarSize * 0.475;
    final indicatorSize = avatarSize * 0.275;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: outerRingSize,
          height: outerRingSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Middle ring
        Container(
          width: middleRingSize,
          height: middleRingSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),

        // Avatar container
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Online indicator
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
