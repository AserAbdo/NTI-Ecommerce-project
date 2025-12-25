import 'package:equatable/equatable.dart';
import '../models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSessionStarted extends ChatState {}

class ChatMessageSending extends ChatState {
  final List<ChatMessage> messages;
  const ChatMessageSending(this.messages);
}

class ChatSuccess extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatSuccess({required this.messages, this.isTyping = false});

  @override
  List<Object> get props => [messages, isTyping];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}
