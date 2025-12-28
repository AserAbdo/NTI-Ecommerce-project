import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';

/// Chat floating action button that navigates to the chatbot
class ChatFloatingButton extends StatelessWidget {
  /// Whether to animate the button down (when navbar is hidden)
  final bool isNavbarHidden;

  /// The height of the navbar for animation offset
  final double navbarHeight;

  const ChatFloatingButton({
    super.key,
    this.isNavbarHidden = false,
    this.navbarHeight = 70,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = ResponsiveHelper.isSmallMobile(context) ? 48.0 : 55.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // Move down when navbar is hidden to take its space
      margin: EdgeInsets.only(bottom: isNavbarHidden ? 0 : navbarHeight),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Material(
          color: AppColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(4),
            bottomLeft: Radius.circular(25),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF1E2746).withValues(alpha: 0.4),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.mainChatBot);
            },
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: ResponsiveHelper.isSmallMobile(context) ? 24 : 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
