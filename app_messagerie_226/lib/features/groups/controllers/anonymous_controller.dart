import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';

// État anonyme de l'utilisateur courant dans un groupe donné
final anonymousStateProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, groupId) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('groups')
      .doc(groupId)
      .collection('members')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

final anonymousControllerProvider =
    Provider((ref) => AnonymousController(ref));

class AnonymousController {
  final Ref _ref;
  AnonymousController(this._ref);

  /// Active ou désactive le mode inconnu dans un groupe.
  /// Si activation : appelle la Cloud Function pour attribuer Inconnu N + couleur.
  /// Si désactivation : remet isAnonymous à false côté Firestore.
  Future<void> toggleAnonymous(String groupId, bool enable) async {
    final user = _ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final memberRef = _ref
        .read(firestoreProvider)
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(user.uid);

    if (!enable) {
      // Désactivation simple côté client
      await memberRef.update({'isAnonymous': false});
      return;
    }

    // Activation : vérifier si un label existe déjà pour cet utilisateur dans ce groupe
    final memberDoc = await memberRef.get();
    final data = memberDoc.data();
    final alreadyHasLabel =
        data != null && (data['anonymousLabel'] as String? ?? '').isNotEmpty;

    if (alreadyHasLabel) {
      // Réutiliser le label existant (même numéro qu'avant)
      await memberRef.update({'isAnonymous': true});
    } else {
      // Nouveau label : incrémenter le compteur atomiquement
      await _assignAnonymousLabel(groupId, user.uid, memberRef);
    }
  }

  Future<void> _assignAnonymousLabel(
    String groupId,
    String uid,
    DocumentReference memberRef,
  ) async {
    final db = _ref.read(firestoreProvider);
    final counterRef =
        db.collection('groups').doc(groupId).collection('meta').doc('anonymousCounter');

    await db.runTransaction((tx) async {
      final counterSnap = await tx.get(counterRef);
      final lastNumber = (counterSnap.data()?['lastNumber'] as int? ?? 0) + 1;
      final color = _anonymousColors[lastNumber % _anonymousColors.length];

      tx.set(counterRef, {'lastNumber': lastNumber}, SetOptions(merge: true));
      tx.update(memberRef, {
        'isAnonymous': true,
        'anonymousLabel': 'Inconnu $lastNumber',
        'anonymousColor': color,
      });
    });
  }

  // Palette de couleurs pour les anonymes (doit correspondre à AppTheme.anonymousColors)
  static const List<String> _anonymousColors = [
    '#1565C0',
    '#6A1B9A',
    '#00695C',
    '#E65100',
    '#4E342E',
    '#37474F',
    '#C62828',
    '#558B2F',
  ];
}
