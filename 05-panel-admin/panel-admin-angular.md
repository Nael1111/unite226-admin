# Panel d'administration web (Angular)

## 1. Objectif

Donner au super-utilisateur une interface web plus confortable qu'un mobile pour gérer
la plateforme au quotidien : création de groupes, gestion des utilisateurs, modération,
supervision.

## 2. Accès

- Authentification réservée aux comptes `role == "superadmin"` (même backend Firebase
  Auth que l'app mobile, ou Auth email/mot de passe dédiée au panel — à trancher ; par
  défaut, réutiliser Firebase Auth avec vérification du rôle côté Firestore)
- Aucun accès utilisateur standard au panel

## 3. Écrans principaux

### 3.1 Tableau de bord
- Nombre total d'utilisateurs, de groupes, de messages envoyés (statistiques globales)
- Groupes les plus actifs

### 3.2 Gestion des groupes
- Liste des groupes (nom, nombre de membres, statut écriture activée/désactivée)
- Créer un nouveau groupe (nom, description)
- Activer/désactiver l'écriture dans un groupe
- Nommer un admin de groupe parmi ses membres
- Voir/gérer les messages épinglés d'un groupe

### 3.3 Gestion des utilisateurs
- Liste des utilisateurs (nom, numéro +226, statut du compte)
- Voir la pièce d'identité recto/verso (accès restreint, journalisé pour audit)
- Supprimer un compte utilisateur
- Voir dans quels groupes un utilisateur est membre

### 3.4 Modération
- Exclure un membre d'un groupe donné
- Restreindre un membre dans un groupe donné
- Historique des actions de modération (qui a fait quoi, quand — recommandé pour la
  traçabilité, notamment vu la sensibilité des données d'identité)

## 4. Stack technique du panel

- Angular (dernière version stable au moment du développement)
- Firebase Web SDK (`@angular/fire` recommandé pour l'intégration idiomatique Angular)
- UI : Angular Material recommandé pour aller vite sur des écrans de gestion type
  back-office (tables, formulaires, dialogues de confirmation)
- Déploiement : Vercel (voir `06-deploiement/guide-deploiement.md`)

## 5. Sécurité spécifique au panel

- Toute action sensible (suppression de compte, exclusion, nomination d'admin) doit
  passer par une Cloud Function dédiée, pas par une écriture directe Firestore depuis
  le panel, pour garder une seule source de vérité sur les permissions
- Journalisation (logs d'audit) des actions de modération et des accès aux pièces
  d'identité, étant donné la sensibilité de ces données
