import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nti_project/core/constants/app_colors.dart';
import 'package:nti_project/features/auth/cubits/auth_cubit.dart';
import 'package:nti_project/features/auth/cubits/auth_state.dart';
import 'package:nti_project/features/chatbot/cubits/chat_cubit.dart';
import 'package:nti_project/features/chatbot/cubits/chat_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user info from AuthCubit
    final authState = context.read<AuthCubit>().state;
    String? userId;
    String? userName;

    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
      userName = authState.user.name;
    }

    return BlocProvider(
      create: (context) =>
          ChatCubit(userId: userId, userName: userName)..initChat(),
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: const BorderRadius.only(
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
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading chat...',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          List<dynamic> messages = [];

                          if (state is ChatSuccess) {
                            messages = state.messages;
                          }
                          if (state is ChatError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<ChatCubit>().initChat();
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Start a conversation!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final reversedMessages = messages.reversed.toList();

                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
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

                    // Typing indicator
                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        if (state is ChatSuccess && state.isTyping) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'AI is typing...',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
            // Message input
            Container(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              child: MessageInputField(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/chatbotIcon.gif"),
            ),
          ),
          const SizedBox(width: 12),
          // Title and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Clear chat button
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Chat?'),
                    content: const Text(
                      'This will delete all messages. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ChatCubit>().clearChat();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
