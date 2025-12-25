import 'package:flutter/material.dart';

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
    return Container(
      color: Colors.white, // This makes the entire input field area white
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white, // White background for the input container
                border: Border.all(color: const Color(0xFF99A8C2)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        hintStyle: TextStyle(
                          color: Color(0xFF99A8C2),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor:
                            Colors.white, // White background for the TextField
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
            child: const CircleAvatar(
              backgroundColor: Color(0xFF3A4D6F),
              child: Icon(Icons.send, color: Colors.white, size: 25),
            ),
          ),
        ],
      ),
    );
  }
}
