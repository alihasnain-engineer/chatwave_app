import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderUID;
  final String senderEmail;
  final String? receiverUID; // optional to stay compatible with existing docs
  final String? conversationKey; // sorted uid pair for stable querying
  final List<dynamic>? participants; // [uidA, uidB] sorted
  final String text;
  final DateTime timestamp;
  final bool? read; // optional - false if not set (unread by default)

  MessageModel({
    required this.id,
    required this.senderUID,
    required this.senderEmail,
    required this.text,
    required this.timestamp,
    this.receiverUID,
    this.conversationKey,
    this.participants,
    this.read,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderUID: data['senderUID'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      receiverUID: data['receiverUID'],
      conversationKey: data['conversationKey'],
      participants: data['participants'],
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderUID': senderUID,
      'senderEmail': senderEmail,
      if (receiverUID != null) 'receiverUID': receiverUID,
      if (conversationKey != null) 'conversationKey': conversationKey,
      if (participants != null) 'participants': participants,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      if (read != null) 'read': read,
    };
  }
}

