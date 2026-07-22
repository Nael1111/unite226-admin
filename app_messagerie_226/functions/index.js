const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ─── 1. onUserCreated : sécurité — s'assurer que role = 'user' à la création ──
exports.onUserCreated = onDocumentCreated('users/{userId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  // Forcer role à 'user' si quelqu'un essaie de se créer superadmin côté client
  if (data.role !== 'user') {
    await event.data.ref.update({ role: 'user' });
  }
});

// ─── 2. setGroupAdmin : nommer un admin de groupe (superadmin uniquement) ──────
exports.setGroupAdmin = onCall(async (request) => {
  _requireAuth(request);
  await _requireSuperAdmin(request.auth.uid);

  const { groupId, targetUid, isAdmin } = request.data;
  if (!groupId || !targetUid) throw new HttpsError('invalid-argument', 'groupId et targetUid requis');

  await db.collection('groups').doc(groupId)
    .collection('members').doc(targetUid)
    .update({ role: isAdmin ? 'groupAdmin' : 'member' });

  await _logAction(request.auth.uid, 'setGroupAdmin', { groupId, targetUid, isAdmin });
  return { success: true };
});

// ─── 3. kickMember : exclure un membre d'un groupe ───────────────────────────
exports.kickMember = onCall(async (request) => {
  _requireAuth(request);
  const { groupId, targetUid } = request.data;
  if (!groupId || !targetUid) throw new HttpsError('invalid-argument', 'groupId et targetUid requis');

  await _requireSuperAdminOrGroupAdmin(request.auth.uid, groupId);

  const batch = db.batch();
  batch.delete(db.collection('groups').doc(groupId).collection('members').doc(targetUid));
  batch.update(db.collection('groups').doc(groupId), {
    membersCount: admin.firestore.FieldValue.increment(-1),
  });
  await batch.commit();

  await _logAction(request.auth.uid, 'kickMember', { groupId, targetUid });
  return { success: true };
});

// ─── 4. restrictMember : restreindre/dé-restreindre un membre ────────────────
exports.restrictMember = onCall(async (request) => {
  _requireAuth(request);
  const { groupId, targetUid, restricted } = request.data;
  if (!groupId || !targetUid) throw new HttpsError('invalid-argument', 'groupId et targetUid requis');

  await _requireSuperAdminOrGroupAdmin(request.auth.uid, groupId);

  await db.collection('groups').doc(groupId)
    .collection('members').doc(targetUid)
    .update({ restricted: !!restricted });

  await _logAction(request.auth.uid, 'restrictMember', { groupId, targetUid, restricted });
  return { success: true };
});

// ─── 5. deleteAccount : supprimer un compte utilisateur ──────────────────────
exports.deleteAccount = onCall(async (request) => {
  _requireAuth(request);
  await _requireSuperAdmin(request.auth.uid);

  const { targetUid } = request.data;
  if (!targetUid) throw new HttpsError('invalid-argument', 'targetUid requis');

  // Marquer comme supprimé dans Firestore
  await db.collection('users').doc(targetUid).update({
    accountStatus: 'deleted',
    deletedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Désactiver le compte Firebase Auth
  await admin.auth().updateUser(targetUid, { disabled: true });

  await _logAction(request.auth.uid, 'deleteAccount', { targetUid });
  return { success: true };
});

// ─── 6. toggleGroupWriting : activer/désactiver l'écriture dans un groupe ────
exports.toggleGroupWriting = onCall(async (request) => {
  _requireAuth(request);
  await _requireSuperAdmin(request.auth.uid);

  const { groupId, writingEnabled } = request.data;
  if (!groupId) throw new HttpsError('invalid-argument', 'groupId requis');

  await db.collection('groups').doc(groupId).update({ writingEnabled: !!writingEnabled });
  await _logAction(request.auth.uid, 'toggleGroupWriting', { groupId, writingEnabled });
  return { success: true };
});

// ─── 7. createGroup : créer un groupe (superadmin uniquement) ─────────────────
exports.createGroup = onCall(async (request) => {
  _requireAuth(request);
  await _requireSuperAdmin(request.auth.uid);

  const { name, description } = request.data;
  if (!name) throw new HttpsError('invalid-argument', 'name requis');

  const groupRef = await db.collection('groups').add({
    name,
    description: description || '',
    createdBy: request.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    writingEnabled: true,
    membersCount: 0,
    pinnedMessageIds: [],
  });

  return { groupId: groupRef.id };
});

// ─── 8. Notification FCM sur nouveau message ──────────────────────────────────
exports.onNewMessage = onDocumentCreated(
  'groups/{groupId}/messages/{messageId}',
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const groupId = event.params.groupId;
    const groupDoc = await db.collection('groups').doc(groupId).get();
    const groupName = groupDoc.data()?.name || 'Groupe';

    // Récupérer tous les membres du groupe
    const membersSnap = await db.collection('groups').doc(groupId)
      .collection('members').get();

    const tokens = [];
    for (const memberDoc of membersSnap.docs) {
      const uid = memberDoc.id;
      if (uid === message.senderId) continue; // pas de notif à soi-même
      const userDoc = await db.collection('users').doc(uid).get();
      const token = userDoc.data()?.fcmToken;
      if (token) tokens.push(token);
    }

    if (tokens.length === 0) return;

    const displayName = message.displayName || 'Quelqu\'un';
    const body = message.type === 'text'
      ? message.content
      : `[${message.type}]`;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title: `${groupName} — ${displayName}`, body },
      data: { groupId, type: 'new_message' },
    });
  }
);

// ─── Helpers ──────────────────────────────────────────────────────────────────
function _requireAuth(request) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentification requise');
}

async function _requireSuperAdmin(uid) {
  const userDoc = await db.collection('users').doc(uid).get();
  if (userDoc.data()?.role !== 'superadmin') {
    throw new HttpsError('permission-denied', 'Accès réservé au super-administrateur');
  }
}

async function _requireSuperAdminOrGroupAdmin(uid, groupId) {
  const userDoc = await db.collection('users').doc(uid).get();
  if (userDoc.data()?.role === 'superadmin') return;
  const memberDoc = await db.collection('groups').doc(groupId)
    .collection('members').doc(uid).get();
  if (memberDoc.data()?.role !== 'groupAdmin') {
    throw new HttpsError('permission-denied', 'Accès réservé aux administrateurs');
  }
}

async function _logAction(actorUid, action, details) {
  await db.collection('moderation_logs').add({
    actorUid,
    action,
    details,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}
