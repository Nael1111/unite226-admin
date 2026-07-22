import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../../auth/controllers/auth_controller.dart';

// Stream temps réel de tous les groupes
final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('groups')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map(Group.fromDoc).toList());
});

// Groupes dont l'utilisateur est membre
final myGroupIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value({});
  return ref
      .watch(firestoreProvider)
      .collectionGroup('members')
      .where(FieldPath.documentId, isEqualTo: user.uid)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.reference.parent.parent!.id).toSet());
});

// Rejoindre un groupe
final groupControllerProvider = Provider((ref) => GroupController(ref));

class GroupController {
  final Ref _ref;
  GroupController(this._ref);

  Future<void> joinGroup(String groupId) async {
    final user = _ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final firestore = _ref.read(firestoreProvider);
    final batch = firestore.batch();

    // Créer le doc membre
    final memberRef = firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(user.uid);

    batch.set(memberRef, {
      'role': 'member',
      'isAnonymous': false,
      'anonymousLabel': '',
      'anonymousColor': '',
      'restricted': false,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Incrémenter membersCount
    final groupRef = firestore.collection('groups').doc(groupId);
    batch.update(groupRef, {'membersCount': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> leaveGroup(String groupId) async {
    final user = _ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final firestore = _ref.read(firestoreProvider);
    final batch = firestore.batch();

    final memberRef = firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(user.uid);

    batch.delete(memberRef);
    batch.update(
      firestore.collection('groups').doc(groupId),
      {'membersCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }
}
