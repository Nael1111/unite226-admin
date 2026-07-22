import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../groups/controllers/group_controller.dart';

const int _pageSize = 30;

// Stream des messages d'un groupe (derniers 30, temps réel)
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, groupId) {
  return ref
      .watch(firestoreProvider)
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(_pageSize)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Message.fromDoc(d, groupId)).toList().reversed.toList());
});

// Messages épinglés d'un groupe
final pinnedMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, groupId) {
  return ref
      .watch(firestoreProvider)
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .where('isPinned', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Message.fromDoc(d, groupId)).toList());
});

final messageControllerProvider =
    Provider((ref) => MessageController(ref));

class MessageController {
  final Ref _ref;
  MessageController(this._ref);

  FirebaseFirestore get _db => _ref.read(firestoreProvider);

  Future<void> sendMessage({
    required String groupId,
    required String content,
    required MessageType type,
    String? replyToMessageId,
  }) async {
    final user = _ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Récupérer le doc membre pour savoir si anonyme
    final memberDoc = await _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(user.uid)
        .get();

    final isAnonymous = memberDoc.data()?['isAnonymous'] ?? false;
    final displayName = isAnonymous
        ? (memberDoc.data()?['anonymousLabel'] ?? 'Inconnu')
        : await _getDisplayName(user.uid);
    final displayColor = isAnonymous
        ? (memberDoc.data()?['anonymousColor'] ?? '#000000')
        : '#000000';

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'displayName': displayName,
      'displayColor': displayColor,
      'type': type.name,
      'content': content,
      'replyToMessageId': replyToMessageId,
      'isPinned': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pinMessage(String groupId, String messageId, bool pin) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': pin});

    final groupRef = _db.collection('groups').doc(groupId);
    if (pin) {
      await groupRef.update({
        'pinnedMessageIds': FieldValue.arrayUnion([messageId])
      });
    } else {
      await groupRef.update({
        'pinnedMessageIds': FieldValue.arrayRemove([messageId])
      });
    }
  }

  Future<String> _getDisplayName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final d = doc.data();
    if (d == null) return 'Utilisateur';
    return '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
  }
}
