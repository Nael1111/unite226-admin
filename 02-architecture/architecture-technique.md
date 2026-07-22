# Architecture technique

## 1. Vue d'ensemble

```
┌─────────────────────┐        ┌─────────────────────┐
│   App mobile         │        │   Panel admin web     │
│   Flutter             │        │   Angular              │
│   (Android/iOS)       │        │   déployé sur Vercel   │
└──────────┬───────────┘        └──────────┬───────────┘
           │                                │
           │      Firebase Auth (phone)     │
           │      Firestore (données)       │
           │      Firebase Storage (médias) │
           │      Cloud Functions (logique) │
           │      Firebase Cloud Messaging  │
           └───────────────┬────────────────┘
                            │
                   ┌────────▼────────┐
                   │     Firebase      │
                   │   (backend as     │
                   │    a service)      │
                   └────────────────────┘

  SQLite : cache local côté mobile uniquement (pas un backend partagé)
```

## 2. Application mobile (Flutter)

### 2.1 Rôle de Flutter
- Client unique multiplateforme (Android + iOS) pour tous les utilisateurs
  (utilisateur standard, admin de groupe, super-utilisateur peut aussi avoir accès
  à ses actions depuis le mobile en plus du panel web)

### 2.2 Rôle de SQLite
- Cache local des messages déjà chargés, pour :
  - Affichage instantané à la réouverture de l'app sans attendre le réseau
  - Fonctionnement en lecture partielle hors-ligne
- Firestore reste la source de vérité ; SQLite est une couche de cache/synchronisation,
  pas une base de données autoritaire
- Package Flutter recommandé : `sqflite` (ou `drift` si l'agent IA préfère un ORM typé,
  à trancher en phase de développement selon la complexité du schéma local)

### 2.3 Packages Flutter clés à prévoir
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`,
  `firebase_messaging`
- `sqflite` (cache local)
- `record` ou `flutter_sound` (enregistrement vocal)
- `video_player` / `chewie` (lecture vidéo)
- `image_picker` (photos, y compris pièce d'identité recto/verso à l'inscription)
- `url_launcher` (redirection des liens externes, avec détection de domaine)
- `share_plus` (le cas échéant)
- `flutter_riverpod` ou `provider` pour la gestion d'état (à trancher selon préférence,
  Riverpod recommandé pour un projet de cette taille)

## 3. Backend (Firebase)

### 3.1 Firebase Authentication
- Authentification par numéro de téléphone (Phone Auth), avec vérification OTP
- Le numéro doit être validé comme commençant par `+226` avant l'envoi du code

### 3.2 Cloud Firestore
- Voir `03-base-de-donnees/schema-firestore-sqlite.md` pour le détail des collections

### 3.3 Firebase Storage
- Stockage des médias : photos de profil, pièces d'identité (accès très restreint via
  règles de sécurité Storage), images/vidéos/vocaux envoyés dans les groupes

### 3.4 Cloud Functions
Logique serveur nécessaire à centraliser côté Functions plutôt que côté client (pour la
sécurité et l'intégrité des données) :
- Attribution du numéro `Inconnu N` et de la couleur associée, par groupe, de façon
  atomique (éviter les collisions de numéro si deux utilisateurs activent le mode
  inconnu au même moment)
- Application des permissions (un client Flutter ne doit jamais pouvoir s'auto-nommer
  admin ou super-utilisateur ; ceci doit être vérifié côté Functions/règles Firestore)
- Suppression de compte (purge des données associées, respect du droit à l'oubli)
- Notifications push (FCM) sur nouveaux messages dans les groupes rejoints

### 3.5 Firebase Cloud Messaging (FCM)
- Notifications de nouveaux messages, mentions, actions admin (exclusion, restriction)

## 4. Panel d'administration web (Angular)

- Application Angular séparée, consommant les mêmes données Firebase (SDK Firebase Web
  ou appels aux mêmes Cloud Functions)
- Déployée sur Vercel
- Voir `05-panel-admin/panel-admin-angular.md` pour les écrans détaillés

## 5. Environnement de développement

- Firebase et GitHub déjà connectés à VS Code via MCP (Model Context Protocol) — l'agent
  IA (Claude Code ou Amazon Q Developer) peut donc :
  - Créer/modifier des ressources Firebase directement si le MCP Firebase l'autorise
  - Committer/pousser sur GitHub directement via le MCP GitHub
- Dépôts suggérés (à confirmer avec le porteur de projet) :
  - Un mono-repo avec deux dossiers (`mobile/` en Flutter, `admin-web/` en Angular), ou
  - Deux dépôts séparés — plus simple pour un déploiement Vercel indépendant du panel
    admin. **Recommandation par défaut : deux dépôts séparés**, car Vercel se déploie
    plus simplement sur un dépôt dédié à l'app Angular.

## 6. Redirection de liens externes (deep linking)

- Utiliser `url_launcher` avec détection du domaine du lien (`tiktok.com`, `facebook.com`,
  `fb.watch`, etc.)
- Sur Android : `LaunchMode.externalApplication` pour privilégier l'app installée
- Sur iOS : Universal Links gérés nativement par TikTok/Facebook si ces apps sont
  installées ; sinon fallback navigateur

## 7. Sécurité — points non négociables

- Règles de sécurité Firestore et Storage strictes : un utilisateur standard ne doit
  jamais pouvoir lire les pièces d'identité d'un autre utilisateur, ni modifier son
  propre rôle, ni écrire dans un groupe où l'écriture est désactivée
- Toute logique de permission (nommer admin, exclure, supprimer un compte) doit être
  vérifiée côté serveur (Cloud Functions + règles Firestore), jamais seulement côté
  client Flutter
