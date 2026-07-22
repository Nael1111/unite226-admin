# Plan de développement étape par étape

Ce plan est écrit pour être suivi séquentiellement par un agent IA de développement
(Claude Code, Amazon Q Developer). Chaque phase doit être validée (compilation propre,
tests manuels de base) avant de passer à la suivante.

## Phase 0 — Initialisation du projet
1. Créer le dépôt GitHub `mobile-app` (Flutter) et `admin-web` (Angular) — via le MCP
   GitHub déjà connecté
2. Initialiser le projet Flutter (`flutter create`)
3. Initialiser le projet Firebase (console Firebase ou CLI `firebase init`), activer :
   Authentication (Phone), Firestore, Storage, Functions, Cloud Messaging
4. Connecter le projet Flutter à Firebase (`flutterfire configure`)
5. Mettre en place la structure de dossiers Flutter (feature-first recommandé : `features/auth`,
   `features/groups`, `features/messaging`, `features/profile`, `core/`)
6. Écrire les règles de sécurité Firestore/Storage de base (deny-by-default)

## Phase 1 — Authentification et inscription
1. Écran de saisie du numéro de téléphone avec validation du préfixe `+226`
2. Intégration Firebase Phone Auth (envoi et vérification OTP)
3. Écran de complétion de profil : nom, prénom, upload photo recto/verso de la pièce
   d'identité, photo de profil
4. Cloud Function `onUserCreated` (ou logique équivalente) pour créer le document
   `users/{userId}` avec `role: "user"` par défaut
5. Stockage sécurisé des photos dans Firebase Storage avec règles restrictives

## Phase 2 — Liste des groupes et adhésion
1. Écran d'accueil listant tous les groupes créés par le super-utilisateur
   (lecture Firestore `groups`)
2. Fonction "rejoindre un groupe" (création du document dans
   `groups/{groupId}/members/{userId}`)
3. Affichage du nombre de membres par groupe (sans limite)

## Phase 3 — Messagerie de groupe (cœur du produit)
1. Écran de conversation de groupe : liste des messages en temps réel (listener
   Firestore), avec cache SQLite en secours
2. Envoi de message texte
3. Envoi de message vocal (enregistrement, upload Storage, lecture)
4. Envoi d'image et de vidéo (upload Storage, prévisualisation, lecture)
5. Envoi de lien avec détection automatique du domaine et redirection
   (TikTok/Facebook/autre) au clic
6. Fonction "répondre" à un message précis (mention/citation, référence
   `replyToMessageId`)
7. Fonction "épingler" un message (mise à jour `isPinned` + liste `pinnedMessageIds`
   du groupe)

## Phase 4 — Mode Inconnu (anonymat)
1. Toggle "Mode inconnu" dans les paramètres utilisateur ou par groupe (à trancher :
   probablement par groupe, voir cahier des charges section 3)
2. Cloud Function d'attribution atomique du label `Inconnu N` + couleur, par groupe
3. Adaptation de l'affichage des messages : nom + couleur "Inconnu" au lieu du nom réel
   quand `isAnonymous == true`
4. S'assurer que l'identité réelle reste accessible côté super-utilisateur pour la
   modération

## Phase 5 — Rôles et permissions
1. Super-utilisateur (via l'app mobile et/ou le panel admin) :
   - Créer un groupe
   - Nommer un admin de groupe
   - Exclure un membre d'un groupe
   - Supprimer un compte utilisateur
   - Activer/désactiver l'écriture dans un groupe
2. Admin de groupe :
   - Restreindre un membre
   - Exclure un membre du groupe
3. Vérification systématique côté Cloud Functions / règles Firestore de chaque action
   (jamais de confiance au client)

## Phase 6 — Notifications
1. Intégration Firebase Cloud Messaging
2. Notification sur nouveau message dans un groupe rejoint
3. Notification sur mention/réponse directe
4. Notification sur action admin (exclusion, restriction)

## Phase 7 — Panel d'administration web (Angular)
Voir `05-panel-admin/panel-admin-angular.md` pour le détail des écrans.
1. Initialisation du projet Angular, intégration Firebase Web SDK
2. Authentification super-utilisateur (accès réservé au panel)
3. Écrans de gestion des groupes, utilisateurs, modération
4. Déploiement sur Vercel (voir `06-deploiement/guide-deploiement.md`)

## Phase 8 — Durcissement et mise en production
1. Revue complète des règles de sécurité Firestore/Storage
2. Tests de charge basiques sur les groupes à forte volumétrie (pas de limite de
   membres = potentiel goulot d'étranglement sur les listeners temps réel, prévoir
   pagination des messages)
3. Politique de rétention/suppression des pièces d'identité (point légal à valider
   avec le porteur de projet avant publication sur les stores)
4. Publication sur Google Play Store et Apple App Store (comptes développeur requis)

## Notes pour l'agent IA
- Ne pas figer de décision de schéma de données concernant les pièces d'identité
  (rétention, chiffrement) sans avoir signalé le point de vigilance légal au porteur
  de projet
- Prévoir la pagination des messages dès la Phase 3 (ne pas charger tout l'historique
  d'un groupe sans limite, malgré l'absence de limite de membres)
- Utiliser Cloud Functions pour toute logique touchant aux rôles/permissions, jamais
  de règle métier sensible uniquement côté Flutter
