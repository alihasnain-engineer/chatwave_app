import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/chat_conversation.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _conversationKey(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Send a message (adds receiverUID + conversationKey + participants for grouping)
  /// CRITICAL: senderUID and receiverUID must be UIDs from users collection (document IDs)
  Future<void> sendMessage({
    required String senderUID,
    required String receiverUID,
    required String senderEmail,
    required String text,
  }) async {
    try {
      final key = _conversationKey(senderUID, receiverUID);
      final participants = [senderUID, receiverUID]..sort();
      
      debugPrint('Sending message: senderUID=$senderUID, receiverUID=$receiverUID, conversationKey=$key');
      
      await _firestore.collection('messages').add({
        'senderUID': senderUID,
        'receiverUID': receiverUID,
        'senderEmail': senderEmail,
        'text': text,
        'conversationKey': key,
        'participants': participants,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false, // New messages are unread by default
      });
      
      debugPrint('Message sent successfully');
    } catch (e) {
      debugPrint('Send message error: $e');
      rethrow;
    }
  }

  /// Get messages stream for a conversation between two users using conversationKey
  /// NO orderBy - sorted in Dart to avoid composite index requirement
  Stream<List<MessageModel>> getConversationMessages({
    required String currentUserUID,
    required String otherUserUID,
  }) {
    final key = _conversationKey(currentUserUID, otherUserUID);
    return _firestore
        .collection('messages')
        .where('conversationKey', isEqualTo: key)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      // Sort by timestamp in Dart (ascending - oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  /// Get recent chats stream (real-time updates) using participants array
  /// NO orderBy - sorted in Dart to avoid composite index requirement
  /// Shows conversations that include the current user, grouped by the other user
  /// CRITICAL: currentUserUID must be UID from users collection (document ID)
  Stream<List<ChatConversation>> getRecentChatsStream(String currentUserUID) {
    debugPrint('📨 getRecentChatsStream: Querying for UID: $currentUserUID');
    return _firestore
        .collection('messages')
        .where('participants', arrayContains: currentUserUID)
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint('📨 getRecentChatsStream: Received ${snapshot.docs.length} messages');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ getRecentChatsStream: No messages found. Checking if UID is correct...');
        debugPrint('   Query UID: $currentUserUID');
        // Debug: Check what UIDs are in the messages collection
        final allMessages = await _firestore.collection('messages').limit(5).get();
        debugPrint('   Sample message participants:');
        for (var doc in allMessages.docs) {
          final data = doc.data();
          final participants = data['participants'] as List<dynamic>?;
          debugPrint('     Message ${doc.id}: participants=$participants');
        }
      }
      final Map<String, MessageModel> lastMessages = {};

      // Process all messages to find latest per conversation
      for (var doc in snapshot.docs) {
        final message = MessageModel.fromFirestore(doc);
        final participants = message.participants?.cast<String>() ?? [];
        if (!participants.contains(currentUserUID) || participants.length < 2) {
          continue;
        }
        final otherUID = participants.firstWhere((uid) => uid != currentUserUID);

        // Keep only the latest message per other user
        if (!lastMessages.containsKey(otherUID) ||
            lastMessages[otherUID]!.timestamp.isBefore(message.timestamp)) {
          lastMessages[otherUID] = message;
        }
      }

      // Build conversation list with unread counts (calculated from already fetched messages)
      final Map<String, int> unreadCounts = {};
      for (var doc in snapshot.docs) {
        final message = MessageModel.fromFirestore(doc);
        // Only count messages received by current user
        if (message.receiverUID == currentUserUID) {
          final participants = message.participants?.cast<String>() ?? [];
          if (participants.contains(currentUserUID) && participants.length >= 2) {
            final otherUID = participants.firstWhere((uid) => uid != currentUserUID);
            final key = _conversationKey(currentUserUID, otherUID);
            
            // Count as unread if read is false or null (old messages without read field)
            final read = message.read;
            if (read == false || read == null) {
              unreadCounts[key] = (unreadCounts[key] ?? 0) + 1;
            }
          }
        }
      }

      final List<ChatConversation> conversations = [];
      for (final entry in lastMessages.entries) {
        final otherUID = entry.key;
        try {
          final userDoc = await _firestore.collection('users').doc(otherUID).get();
          if (userDoc.exists) {
            final otherUser = UserModel.fromFirestore(userDoc.data()!, otherUID);
            final key = _conversationKey(currentUserUID, otherUID);
            final unreadCount = unreadCounts[key] ?? 0;
            
            conversations.add(ChatConversation(
              otherUserUID: otherUID,
              otherUser: otherUser,
              lastMessage: entry.value,
              unreadCount: unreadCount,
            ));
          }
        } catch (e) {
          debugPrint('Error fetching user $otherUID: $e');
        }
      }

      // Sort by last message timestamp in Dart (most recent first)
      conversations.sort((a, b) {
        if (a.lastMessage == null && b.lastMessage == null) return 0;
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
      });

      return conversations;
    });
  }

  /// Get unread message count for a conversation
  Stream<int> getUnreadCount({
    required String currentUserUID,
    required String otherUserUID,
  }) {
    final key = _conversationKey(currentUserUID, otherUserUID);
    return _firestore
        .collection('messages')
        .where('conversationKey', isEqualTo: key)
        .where('receiverUID', isEqualTo: currentUserUID)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final read = data['read'] as bool?;
        // Count as unread if read is false or null (old messages without read field)
        if (read == false || read == null) {
          count++;
        }
      }
      return count;
    });
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead({
    required String currentUserUID,
    required String otherUserUID,
  }) async {
    try {
      final key = _conversationKey(currentUserUID, otherUserUID);
      final unreadMessages = await _firestore
          .collection('messages')
          .where('conversationKey', isEqualTo: key)
          .where('receiverUID', isEqualTo: currentUserUID)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        final data = doc.data();
        final read = data['read'] as bool?;
        // Only update if not already read
        if (read == false || read == null) {
          batch.update(doc.reference, {'read': true});
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  /// Search user by email
  Future<UserModel?> searchUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return UserModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      debugPrint('Search user error: $e');
      return null;
    }
  }
}

