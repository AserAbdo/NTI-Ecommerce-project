import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final inputBgColor = isDark ? const Color(0xFF252536) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : const Color(0xFF99A8C2);
    final hintColor = isDark ? Colors.grey.shade500 : const Color(0xFF99A8C2);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: inputBgColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        hintStyle: TextStyle(color: hintColor, fontSize: 16),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: inputBgColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: isLoading ? () {} : onSend,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.send, color: Colors.white, size: 25),
            ),
          ),
        ],
      ),
    );
  }
}
