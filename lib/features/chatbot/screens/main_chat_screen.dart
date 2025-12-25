import 'package:flutter/material.dart';
import 'package:nti_project/core/constants/app_colors.dart';
import 'package:nti_project/core/constants/app_routes.dart';
import 'package:nti_project/core/utils/text_style.dart';

class MainChatbotScreen extends StatelessWidget {
  const MainChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(context),
              const Spacer(flex: 1),
              const Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/chatbotIcon.gif",
                    ),
                    backgroundColor: Colors.white,
                    radius: 70,
                  ),
                ],
              ),
              const Spacer(flex: 1),
              const Text(
                "Welcome to Your\nAI Assistant ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              SizedBox(
                width: size.width * 0.7,
                child: Text(
                  "Using this software, you can ask questions and receive answers using artificial intelligence assistant",
                  style: TextStyles.text14Light.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 8),
              SizedBox(
                height: size.height * 0.2,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      height: size.height * 0.2 * 0.5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Column(
                        children: [
                          const Text(
                            "Explore AI ChatBots",
                            style: TextStyle(
                              color: AppColors.surface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.chatBot);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.chat_bubble,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () {
            Navigator.canPop(context) ? Navigator.pop(context) : {};
          },
        ),
      ),
    );
  }
}
