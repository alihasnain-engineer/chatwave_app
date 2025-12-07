import '../models/chat.dart';
import '../models/chat_message.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal();

  final List<Chat> chats = [];

  List<Chat> getAllChats() => chats;

  void addChat(String name) {
    chats.add(Chat(id: DateTime.now().toString(), name: name));
  }

  void addMessage(Chat chat, String message) {
    chat.messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        message: message,
        isMe: true,
        createdAt: DateTime.now(),
      ),
    );
  }
}
