import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final Dio _dio = Dio();

  final String _n8nUrl =
      'https://vella-niftier-gertrude.ngrok-free.dev/webhook-test/3cfa783e-2d8d-45eb-a8b7-3da10eabd8be';

  late Box<ChatMessage> _messagesBox;
  List<ChatMessage> _messages = [];

  Future<void> initChat() async {
    emit(ChatLoading());
    try {
      _messagesBox = await Hive.openBox<ChatMessage>('chat_messages');
      _messages = _messagesBox.values.toList();

      if (_messages.isEmpty) {
        await _addLocalWelcomeMessage();
      } else {
        emit(ChatSuccess(messages: List.from(_messages)));
      }
    } catch (e) {
      emit(ChatError("Failed to load local messages: $e"));
    }
  }

  Future<void> _addLocalWelcomeMessage() async {
    // final user = UserStorage.getUserData();
    final welcomeText =
        "أهلاً بك يا ${'صديقي'}! 👋\nأنا المساعد الذكي الخاص بالمتجر، كيف يمكنني مساعدتك اليوم؟";

    final welcomeMsg = ChatMessage(
      text: welcomeText,
      isUser: false,
      time: _getCurrentTime(),
    );

    await _addMessageToBox(welcomeMsg);
    emit(ChatSuccess(messages: List.from(_messages)));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      time: _getCurrentTime(),
    );

    await _addMessageToBox(userMsg);

    emit(ChatSuccess(messages: List.from(_messages), isTyping: true));

    try {
      // final user = UserStorage.getUserData();

      final response = await _dio.post(
        _n8nUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {"userId": "zWJ1oaWdmEVeFncV5kMmupLaqkL2", "message": text},
      );

      final botReplyText =
          response.data['message'] ?? "عذراً، لم أتمكن من فهم الرد.";

      final botMsg = ChatMessage(
        text: botReplyText,
        isUser: false,
        time: _getCurrentTime(),
      );

      await _addMessageToBox(botMsg);
      emit(ChatSuccess(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      final errorMsg = ChatMessage(
        text: 'فشل الاتصال بالخادم، يرجى المحاولة لاحقاً.',
        isUser: false,
        time: _getCurrentTime(),
      );
      print("API Error: $e");
      emit(ChatSuccess(messages: List.from(_messages), isTyping: false));
    }
  }

  Future<void> _addMessageToBox(ChatMessage message) async {
    await _messagesBox.add(message);
    _messages.add(message);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<void> clearChat() async {
    await _messagesBox.clear();
    _messages.clear();
    await _addLocalWelcomeMessage();
  }
}
