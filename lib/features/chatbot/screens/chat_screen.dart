import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nti_project/core/constants/app_colors.dart';
import 'package:nti_project/features/auth/models/user_model.dart';
import 'package:nti_project/features/chatbot/cubits/chat_cubit.dart';
import 'package:nti_project/features/chatbot/cubits/chat_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..initChat(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = UserModel(
    id: "zWJ1oaWdmEVeFncV5kMmupLaqkL2",
    name: "name",
    email: "email",
    phone: "phone",
    address: "address",
  );

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: BlocConsumer<ChatCubit, ChatState>(
                        listener: (context, state) {
                          if (state is ChatSuccess ||
                              state is ChatMessageSending) {
                            _scrollToBottom();
                          }
                        },
                        builder: (context, state) {
                          if (state is ChatLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<dynamic> messages = [];
                          bool isTyping = false;

                          if (state is ChatSuccess) {
                            messages = state.messages;
                            isTyping = state.isTyping;
                          }

                          final reversedMessages = messages.reversed.toList();

                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            itemCount: reversedMessages.length,
                            itemBuilder: (context, index) {
                              final msg = reversedMessages[index];
                              return MessageBubble(
                                text: msg.text,
                                isUser: msg.isUser,
                                showAvatar: true,
                                time: msg.time,
                                image: "",
                              );
                            },
                          );
                        },
                      ),
                    ),

                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        if (state is ChatSuccess && state.isTyping) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Chatbot is typing...',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            MessageInputField(
              controller: _messageController,
              isLoading: false,
              onSend: () {
                final text = _messageController.text;
                if (text.isNotEmpty) {
                  context.read<ChatCubit>().sendMessage(text);
                  _messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 25),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Center(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surface,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 30,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
