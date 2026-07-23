import { Injectable, inject } from '@angular/core';
import { Auth, signInWithEmailAndPassword, signOut, user } from '@angular/fire/auth';
import {
  Firestore, collection, collectionData, doc, updateDoc,
  deleteDoc, query, orderBy, limit, where, getDocs, addDoc, serverTimestamp
} from '@angular/fire/firestore';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { Observable, from } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private auth = inject(Auth);
  private firestore = inject(Firestore);
  private functions = inject(Functions);

  readonly currentUser$ = user(this.auth);

  // ── Auth ─────────────────────────────────────────────────────────────────
  login(email: string, password: string) {
    return signInWithEmailAndPassword(this.auth, email, password);
  }

  logout() {
    return from(signOut(this.auth));
  }

  // ── Groupes ──────────────────────────────────────────────────────────────
  getGroups(): Observable<any[]> {
    return collectionData(collection(this.firestore, 'groups'), { idField: 'id' }) as Observable<any[]>;
  }

  createGroup(name: string, description: string) {
    const fn = httpsCallable(this.functions, 'createGroup');
    return from(fn({ name, description }));
  }

  deleteGroup(groupId: string) {
    return from(deleteDoc(doc(this.firestore, `groups/${groupId}`)));
  }

  toggleGroupWriting(groupId: string, enabled: boolean) {
    return from(updateDoc(doc(this.firestore, `groups/${groupId}`), { writingEnabled: enabled }));
  }

  // ── Utilisateurs ─────────────────────────────────────────────────────────
  getUsers(): Observable<any[]> {
    return collectionData(collection(this.firestore, 'users'), { idField: 'id' }) as Observable<any[]>;
  }

  banUser(uid: string, banned: boolean) {
    return from(updateDoc(doc(this.firestore, `users/${uid}`), { banned }));
  }

  // ── Messages ─────────────────────────────────────────────────────────────
  deleteMessage(groupId: string, messageId: string) {
    return from(deleteDoc(doc(this.firestore, `groups/${groupId}/messages/${messageId}`)));
  }

  getMessages(groupId: string): Observable<any[]> {
    const ref = query(
      collection(this.firestore, `groups/${groupId}/messages`),
      orderBy('createdAt', 'desc')
    );
    return from(getDocs(ref)).pipe(
      map(snap => snap.docs.map(d => ({ id: d.id, ...d.data() })))
    );
  }

  // ── Logs de modération ───────────────────────────────────────────────────
  getModerationLogs(): Observable<any[]> {
    const ref = query(collection(this.firestore, 'moderation_logs'), orderBy('timestamp', 'desc'), limit(50));
    return collectionData(ref, { idField: 'id' }) as Observable<any[]>;
  }

  logModerationAction(action: string, targetUid: string, details: any) {
    return from(addDoc(collection(this.firestore, 'moderation_logs'), {
      action,
      actorUid: this.auth.currentUser?.uid ?? 'admin',
      targetUid,
      details,
      timestamp: serverTimestamp(),
    }));
  }

  // ── Validations ───────────────────────────────────────────────────────────
  getPendingUsers(): Observable<any[]> {
    const ref = query(collection(this.firestore, 'users'), where('accountStatus', '==', 'pending'));
    return collectionData(ref, { idField: 'id' }) as Observable<any[]>;
  }

  approveUser(uid: string) {
    const fn = httpsCallable(this.functions, 'approveUser');
    return from(fn({ targetUid: uid }));
  }

  rejectUser(uid: string, reason: string) {
    const fn = httpsCallable(this.functions, 'rejectUser');
    return from(fn({ targetUid: uid, reason }));
  }

  // ── Stats dashboard ──────────────────────────────────────────────────────
  async getStats(): Promise<{ users: number; groups: number }> {
    const [usersSnap, groupsSnap] = await Promise.all([
      getDocs(collection(this.firestore, 'users')),
      getDocs(collection(this.firestore, 'groups')),
    ]);
    return { users: usersSnap.size, groups: groupsSnap.size };
  }
}
