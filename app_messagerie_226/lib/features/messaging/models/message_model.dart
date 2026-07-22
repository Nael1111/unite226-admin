import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, voice, video, image, link }

class Message {
  final String id;
  final String groupId;
  final String senderId;
  final String displayName;
  final String displayColor;
  final MessageType type;
  final String content;
  final String? replyToMessageId;
  final bool isPinned;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.displayName,
    required this.displayColor,
    required this.type,
    required this.content,
    this.replyToMessageId,
    required this.isPinned,
    required this.createdAt,
  });

  factory Message.fromDoc(DocumentSnapshot doc, String groupId) {
    final d = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      groupId: groupId,
      senderId: d['senderId'] ?? '',
      displayName: d['displayName'] ?? '',
      displayColor: d['displayColor'] ?? '#000000',
      type: MessageType.values.firstWhere(
        (e) => e.name == (d['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      content: d['content'] ?? '',
      replyToMessageId: d['replyToMessageId'],
      isPinned: d['isPinned'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'displayName': displayName,
        'displayColor': displayColor,
        'type': type.name,
        'content': content,
        'replyToMessageId': replyToMessageId,
        'isPinned': isPinned,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
