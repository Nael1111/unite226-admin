# Guide de déploiement

## 1. Environnement de développement

- VS Code avec MCP Firebase et MCP GitHub déjà connectés
- Agent de développement : Claude Code ou Amazon Q Developer, exécuté en local dans
  VS Code, avec accès à ces MCP pour créer des ressources et pousser du code directement

## 2. Firebase (backend)

1. Créer le projet Firebase depuis la console ou via CLI (`firebase projects:create`)
2. Activer les services : Authentication (Phone provider), Firestore, Storage,
   Functions, Cloud Messaging
3. Définir les règles de sécurité Firestore et Storage (voir
   `03-base-de-donnees/schema-firestore-sqlite.md` section 3)
4. Déployer les Cloud Functions : `firebase deploy --only functions`
5. Déployer les règles : `firebase deploy --only firestore:rules,storage:rules`
6. Prévoir un projet Firebase séparé pour un environnement de test/staging avant la
   production (recommandé, à valider selon le budget du porteur de projet — Firebase
   propose un plan gratuit Spark limité, un plan Blaze à l'usage nécessaire dès que les
   Cloud Functions ou un volume significatif sont utilisés)

## 3. Application mobile (Flutter)

1. Build Android : `flutter build appbundle` (format requis par le Google Play Store)
2. Build iOS : `flutter build ipa` (nécessite un compte Apple Developer et macOS/Xcode
   pour la signature)
3. Publication :
   - Google Play Console (compte développeur payant, one-time fee)
   - Apple App Store Connect (compte développeur, abonnement annuel)
4. Gestion des variables d'environnement (clés Firebase par environnement dev/prod) via
   des fichiers de configuration distincts (`google-services.json` /
   `GoogleService-Info.plist` par environnement, ou flavors Flutter)

## 4. Panel admin web (Angular) sur Vercel

1. Dépôt GitHub dédié au panel admin (`admin-web`), poussé via le MCP GitHub
2. Connecter le dépôt à Vercel (import direct depuis GitHub dans le dashboard Vercel,
   ou CLI `vercel`)
3. Build command Angular : `ng build --configuration production`
4. Output directory à configurer sur Vercel selon la structure Angular
   (`dist/<nom-projet>` généralement)
5. Variables d'environnement Firebase (clé API, projectId, etc.) à renseigner dans les
   "Environment Variables" du projet Vercel, pas commitées en clair dans le dépôt
6. Chaque push sur la branche principale déclenche un redéploiement automatique
   (comportement par défaut de Vercel avec GitHub)

## 5. CI/CD recommandé (à mettre en place progressivement)

- GitHub Actions pour :
  - Lancer les tests Flutter (`flutter test`) et l'analyse statique (`flutter analyze`)
    à chaque pull request
  - Lancer les tests Angular (`ng test`) à chaque pull request sur `admin-web`
  - Déployer automatiquement les Cloud Functions et les règles Firestore sur merge vers
    la branche principale (via `firebase deploy` dans le workflow, avec un token de
    service Firebase stocké en secret GitHub)
- Vercel gère déjà le CI/CD du panel admin nativement, pas besoin de le dupliquer dans
  GitHub Actions pour cette partie

## 6. Checklist avant mise en production

- [ ] Règles de sécurité Firestore/Storage testées (y compris tentatives d'accès non
      autorisé aux pièces d'identité)
- [ ] Point légal sur la collecte/rétention des pièces d'identité validé avec le porteur
      de projet
- [ ] Pagination des messages en place (pas de chargement illimité de l'historique)
- [ ] Comptes développeur Google Play / Apple App Store créés
- [ ] Projet Firebase en plan Blaze si usage des Cloud Functions en production
- [ ] Variables d'environnement de production séparées de celles de développement
