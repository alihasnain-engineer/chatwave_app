import 'message_model.dart';
import 'user_model.dart';

class ChatConversation {
  final String otherUserUID;
  final UserModel otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.otherUserUID,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  String get chatId => otherUserUID;
  String get displayName => otherUser.displayNameOrFullName;
}

