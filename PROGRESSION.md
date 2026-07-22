# Fichier de progression — Projet Unité 226
> Mis à jour à chaque étape. Permet à l'agent de reprendre exactement où il s'est arrêté.

---

## ÉTAT GLOBAL : 🔄 Phase 8 en cours (Phases 0-7 terminées)

---

## ✅ FAIT

- [x] Projets créés : `app_messagerie_226/` (Flutter) et `admin-web/` (Angular 21)
- [x] Fichiers de contexte rédigés (01 à 06)
- [x] Fichier PROGRESSION.md créé

### Phase 0 — COMPLÈTE ✅
- [x] `pubspec.yaml` Flutter mis à jour avec toutes les dépendances (Firebase, Riverpod, GoRouter, SQLite, médias)
- [x] `flutter pub get` exécuté — 110 packages installés
- [x] Structure feature-first Flutter créée : `lib/core/`, `lib/features/auth|groups|messaging|profile/`
- [x] `lib/core/theme.dart` — thème couleurs Burkina (vert #006B3C, rouge #EF2B2D) + palette anonymes
- [x] `lib/core/router.dart` — GoRouter avec toutes les routes nommées + placeholders
- [x] `lib/core/firebase_options.dart` — vraies clés Firebase (projet unite226-app)
- [x] `lib/main.dart` — réécrit avec Firebase.initializeApp + ProviderScope + MaterialApp.router
- [x] Angular : `@angular/fire`, `@angular/material`, `@angular/cdk` installés
- [x] Angular : structure `core/guards|services|models`, `features/auth|dashboard|groups|users|moderation`, `shared/` créée
- [x] Angular : `src/environments/environment.ts` + `environment.prod.ts` (placeholders Firebase)
- [x] Angular : `app.config.ts` configuré avec provideFirebaseApp, provideAuth, provideFirestore, provideStorage
- [x] Angular : `app.routes.ts` avec lazy loading + superadminGuard
- [x] Angular : `core/guards/superadmin.guard.ts` créé
- [x] Angular : composants placeholders créés (login, dashboard, groups, users, moderation)

---

### Phase 1 — COMPLÈTE ✅
- [x] `firebase_options.dart` — vraies clés Firebase (projet unite226-app)
- [x] `google-services.json` téléchargé dans `android/app/`
- [x] `GoogleService-Info.plist` téléchargé dans `ios/Runner/`
- [x] App Android Firebase créée (appId: 1:80911235759:android:e0fc444fb1f827ac91725a)
- [x] App iOS Firebase créée (appId: 1:80911235759:ios:76c502defd42fc7f91725a)
- [x] `AuthController` Riverpod — sendOtp, verifyOtp, état auth complet
- [x] `PhoneInputScreen` — saisie +226 avec validation 8 chiffres
- [x] `OtpVerifyScreen` — 6 cases OTP avec auto-focus
- [x] `ProfileSetupScreen` — nom, prénom, photo profil, pièce d'identité recto/verso + upload Storage
- [x] `router.dart` — redirect automatique selon état Firebase Auth
- [ ] ⚠️ Firestore API à activer manuellement : https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=unite226-app
- [ ] ⚠️ Firebase Phone Auth à activer : https://console.firebase.google.com/project/unite226-app/authentication/providers
- [ ] ⚠️ Firebase Storage à activer : https://console.firebase.google.com/project/unite226-app/storage

### Phase 2 — COMPLÈTE ✅
- [x] `firestore.rules` — règles complètes déployées (users, groups, members, messages, meta)
- [x] `storage.rules` — règles accès restreint pièces d'identité
- [x] `firestore.indexes.json` — index messages déployés
- [x] `firebase.json` configuré
- [x] Firestore base créée (eur3)
- [x] `group_model.dart` — modèle Group
- [x] `GroupController` — joinGroup, leaveGroup, streams temps réel
- [x] `GroupListScreen` — liste temps réel, bouton rejoindre, statut écriture
- [x] Firebase Storage **remplacé par Cloudinary** (plan gratuit 25 Go, zéro carte bancaire)
- [x] `lib/core/services/cloudinary_service.dart` créé
- [x] `firebase_storage` retiré du pubspec
- [x] `ProfileSetupScreen`, `MessageInputBar` mis à jour pour Cloudinary
- [ ] ⚠️ Renseigner `CloudinaryConfig.cloudName` et `CloudinaryConfig.uploadPreset` dans `cloudinary_service.dart`

### Phase 3 — COMPLÈTE ✅
- [x] `message_model.dart` — modèle Message (text, voice, video, image, link)
- [x] `MessageController` — sendMessage, pinMessage, streams paginés
- [x] `GroupChatScreen` — conversation temps réel, messages épinglés, réponse
- [x] `MessageBubble` — bulles, réponse citée, deep link TikTok/Facebook, épinglage
- [x] `MessageInputBar` — texte, vocal (record), image, vidéo, lien auto-détecté

### Phase 4 — COMPLÈTE ✅
- [x] `anonymous_controller.dart` — toggleAnonymous, attribution atomique Inconnu N + couleur via transaction Firestore
- [x] `anonymous_toggle.dart` — widget toggle dans l'AppBar du chat, dialog de confirmation
- [x] Réutilisation du label existant si l'utilisateur a déjà été anonyme dans ce groupe

### Phase 5 — COMPLÈTE ✅
- [x] Cloud Functions `functions/index.js` :
  - [x] `onUserCreated` — force role='user' à la création
  - [x] `setGroupAdmin` — nommer admin (superadmin uniquement)
  - [x] `kickMember` — exclure un membre (superadmin ou groupAdmin)
  - [x] `restrictMember` — restreindre/dé-restreindre (superadmin ou groupAdmin)
  - [x] `deleteAccount` — désactiver compte Firebase Auth (superadmin uniquement)
  - [x] `toggleGroupWriting` — activer/désactiver écriture (superadmin uniquement)
  - [x] `createGroup` — créer un groupe (superadmin uniquement)
  - [x] `_logAction` — journalisation dans `moderation_logs`

### Phase 6 — COMPLÈTE ✅
- [x] `onNewMessage` Cloud Function — notification FCM sur nouveau message
- [x] `lib/core/services/fcm_service.dart` — initialisation FCM + sauvegarde token

### Phase 7 — COMPLÈTE ✅
- [x] `AdminService` — login/logout Firebase Auth, getGroups, getUsers, getModerationLogs, getStats, toggleGroupWriting
- [x] `LoginComponent` — formulaire email/mot de passe avec gestion d'erreur
- [x] `DashboardComponent` — stats (users, groups) + liste groupes temps réel
- [x] `GroupsComponent` — tableau groupes avec toggle écriture
- [x] `UsersComponent` — tableau utilisateurs avec recherche
- [x] `ModerationComponent` — journal des actions de modération
- [x] `LayoutComponent` — sidenav Material avec navigation et déconnexion
- [x] `superadmin.guard.ts` — protection des routes admin

## 🔄 EN COURS — Phase 8 : Déploiement Vercel

### Phase 8 — EN COURS 🔄
- [x] Build Angular vérifié — 0 erreur (`npm run build` ✅)
- [x] `admin-web/vercel.json` créé — outputDirectory: `dist/admin-web/browser`, rewrites SPA
- [x] `vercel.json` poussé sur GitHub (repo: unite226-admin)
- [ ] **PROCHAINE ÉTAPE** : Connecter le repo `unite226-admin` sur https://vercel.com/new
  - Sélectionner le repo `unite226-admin`
  - Root Directory : `admin-web` (si le repo contient tout le workspace) ou laisser vide si repo dédié
  - Ajouter les variables d'environnement Firebase :
    - `NG_APP_FIREBASE_API_KEY`
    - `NG_APP_FIREBASE_AUTH_DOMAIN`
    - `NG_APP_FIREBASE_PROJECT_ID`
    - `NG_APP_FIREBASE_STORAGE_BUCKET`
    - `NG_APP_FIREBASE_MESSAGING_SENDER_ID`
    - `NG_APP_FIREBASE_APP_ID`
  - Cliquer "Deploy"
- [ ] Vérifier le déploiement Vercel (URL publique)
- [ ] Créer le compte superadmin Firebase (email/mot de passe) via Firebase Console
- [ ] Build Flutter Android (APK release)

---

## ⏳ À FAIRE — Reste de la Phase 8

### Déploiement Vercel (panel admin)
1. Aller sur https://vercel.com/new
2. Importer le repo GitHub `unite226-admin`
3. Configurer les variables d'environnement (voir ci-dessus)
4. Déployer

### Compte superadmin
- Créer un utilisateur email/mot de passe dans Firebase Console > Authentication
- Dans Firestore, créer manuellement le document `users/{uid}` avec `{ role: "superadmin" }`

### Build Flutter Android
- `flutter build apk --release` dans `app_messagerie_226/`
- Nécessite un keystore de signature

---

## 📝 DÉCISIONS EN ATTENTE (à valider avec le porteur de projet)

1. Légal : politique de rétention/suppression des pièces d'identité
2. Le mode inconnu est-il par groupe ou global ? ✅ Retenu : par groupe
3. L'épinglage de message est-il réservé aux admins ou ouvert à tous ?
4. Auth panel admin : réutiliser Firebase Phone Auth ou créer un compte email/mdp dédié ? ✅ Retenu : email/mdp
5. Budget Firebase : plan Spark (gratuit) ou Blaze (requis pour Cloud Functions en prod) ?

---

## 🗂️ STRUCTURE CIBLE DES PROJETS

### Flutter — lib/
```
lib/
  main.dart
  core/
    theme.dart
    router.dart
    firebase_options.dart
    services/
      cloudinary_service.dart
      fcm_service.dart
  features/
    auth/
      screens/
      widgets/
      controllers/
    groups/
      screens/
      widgets/
      controllers/
    messaging/
      screens/
      widgets/
      controllers/
    profile/
      screens/
      widgets/
```

### Angular — src/app/
```
src/app/
  core/
    guards/
    services/
    models/
  features/
    auth/
    dashboard/
    groups/
    users/
    moderation/
  shared/
    components/
    pipes/
```
