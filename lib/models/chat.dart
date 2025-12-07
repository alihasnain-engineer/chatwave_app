import 'chat_message.dart';

class Chat {
  final String id;
  final String name;
  List<ChatMessage> messages;

  Chat({
    required this.id,
    required this.name,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}
