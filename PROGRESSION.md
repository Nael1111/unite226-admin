# Fichier de progression — Projet Unité 226
> Mis à jour à chaque étape. Permet à l'agent de reprendre exactement où il s'est arrêté.

---

## ÉTAT GLOBAL : 🔄 Phase 4 en cours (Phases 0-3 terminées)

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
- [x] `lib/core/firebase_options.dart` — placeholder (à remplacer par `flutterfire configure`)
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

## 🔄 EN COURS — Phase 4 : Mode Inconnu (anonymat)

---

## ⏳ À FAIRE — Phases suivantes

### Phase 1 — Auth Flutter
- [ ] Écran saisie numéro +226
- [ ] Intégration Firebase Phone Auth + OTP
- [ ] Écran complétion profil (nom, prénom, photo pièce d'identité, photo profil)
- [ ] Cloud Function `onUserCreated`

### Phase 2 — Liste des groupes Flutter
- [ ] Écran liste des groupes (lecture Firestore)
- [ ] Rejoindre un groupe

### Phase 3 — Messagerie Flutter
- [ ] Écran conversation temps réel
- [ ] Envoi texte, vocal, image, vidéo, lien
- [ ] Répondre à un message, épingler
- [ ] Cache SQLite

### Phase 4 — Mode Inconnu
- [ ] Toggle anonymat par groupe
- [ ] Cloud Function attribution atomique Inconnu N + couleur

### Phase 5 — Rôles & permissions
- [ ] Cloud Functions pour toutes les actions sensibles
- [ ] Règles Firestore/Storage complètes

### Phase 6 — Notifications FCM
- [ ] Intégration FCM Flutter
- [ ] Cloud Functions triggers notifications

### Phase 7 — Panel admin Angular
- [ ] Auth superadmin
- [ ] Dashboard stats
- [ ] Gestion groupes
- [ ] Gestion utilisateurs
- [ ] Modération

### Phase 8 — Durcissement & déploiement
- [ ] Revue règles sécurité
- [ ] Pagination messages
- [ ] CI/CD GitHub Actions
- [ ] Déploiement Vercel panel admin
- [ ] Build Flutter Android/iOS

---

## 📝 DÉCISIONS EN ATTENTE (à valider avec le porteur de projet)

1. Légal : politique de rétention/suppression des pièces d'identité
2. Le mode inconnu est-il par groupe ou global ? (hypothèse retenue : par groupe)
3. L'épinglage de message est-il réservé aux admins ou ouvert à tous ?
4. Auth panel admin : réutiliser Firebase Phone Auth ou créer un compte email/mdp dédié ?
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
