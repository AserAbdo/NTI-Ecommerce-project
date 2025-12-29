import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_cushed_image.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool showAvatar;
  final String? time;
  final String image;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.showAvatar = false,
    this.time,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors for dark mode
    final userBubbleColor = isDark
        ? AppColors.primary.withOpacity(0.3)
        : const Color(0xFFCFD9E9);
    final botBubbleBorderColor = isDark
        ? Colors.grey.shade700
        : const Color(0xFFCFD9E9);
    final textColor = isDark ? Colors.white : const Color(0xFF15243F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser && showAvatar)
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/chatbotIcon.gif'),
            ),
          if (!isUser && showAvatar) const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isUser ? userBubbleColor : Colors.transparent,
                    border: isUser
                        ? null
                        : Border.all(color: botBubbleBorderColor),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isUser ? 12 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      time!,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade500 : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser && showAvatar) const SizedBox(width: 10),
          if (isUser && showAvatar)
            CustomCushedImage(image: image, height: 40, width: 40),
        ],
      ),
    );
  }
}
