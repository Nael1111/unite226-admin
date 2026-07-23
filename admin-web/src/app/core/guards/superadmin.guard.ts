import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Auth, user } from '@angular/fire/auth';
import { Firestore, doc, getDoc } from '@angular/fire/firestore';
import { firstValueFrom } from 'rxjs';

export const superadminGuard: CanActivateFn = async () => {
  const auth = inject(Auth);
  const firestore = inject(Firestore);
  const router = inject(Router);

  const currentUser = await firstValueFrom(user(auth));
  if (!currentUser) {
    router.navigate(['/auth/login']);
    return false;
  }

  const userDoc = await getDoc(doc(firestore, `users/${currentUser.uid}`));
  if (userDoc.exists() && userDoc.data()['role'] === 'superadmin') {
    return true;
  }

  router.navigate(['/auth/login']);
  return false;
};
