# Contexte projet — Application de messagerie communautaire (Burkina Faso, +226)

Ce dossier contient l'ensemble du contexte nécessaire pour qu'un agent IA de développement
(Claude Code, Amazon Q Developer, ou équivalent) puisse concevoir, développer et déployer
le produit de bout en bout, sans allers-retours supplémentaires avec le porteur de projet.

## Comment utiliser ce contexte (ordre de lecture recommandé)

1. `01-specifications/cahier-des-charges.md` — Ce que le produit doit faire (fonctionnel)
2. `02-architecture/architecture-technique.md` — Comment c'est construit (technique)
3. `03-base-de-donnees/schema-firestore-sqlite.md` — Modèle de données
4. `04-plan-developpement/phases.md` — Plan de développement étape par étape
5. `05-panel-admin/panel-admin-angular.md` — Spécifications du panel d'administration web
6. `06-deploiement/guide-deploiement.md` — Déploiement (Firebase, Vercel, GitHub, CI/CD)

## Résumé du produit en une phrase

Une application mobile Flutter de messagerie de groupe (façon WhatsApp) où seul un
super-utilisateur (admin plateforme) crée les groupes de discussion, avec un mode
"anonyme" activable par utilisateur, sans messagerie privée entre utilisateurs,
appuyée par un panel d'administration web (Angular) et un backend Firebase.

## Contraintes de projet connues

- Porteur de projet : développeur solo, étudiant, en stage (contexte MIAGE / IBAM,
  stage chez Tanga Group)
- Firebase et GitHub déjà connectés à VS Code via MCP
- Agent de développement visé : Claude Code ou Amazon Q Developer, en local dans VS Code
- Panel admin web prévu en Angular, déploiement visé sur Vercel
- Stack imposée : Flutter (mobile), Firebase (backend), SQLite (cache local mobile)
- Marché cible : Burkina Faso — indicatif téléphonique +226 obligatoire à l'inscription

## Ce que ce contexte NE couvre PAS encore (décisions à prendre avec le porteur de projet)

- Design visuel définitif (charte graphique, logo, palette exacte) — des propositions
  raisonnables sont faites dans `02-architecture` mais restent à valider
- Modèle économique / monétisation (non mentionné dans le brief initial)
- Politique de modération de contenu détaillée (au-delà des droits admin/super-admin)
- Conformité légale précise (protection des données personnelles, stockage des pièces
  d'identité) — voir note de vigilance dans `01-specifications/cahier-des-charges.md`

Un agent IA reprenant ce dossier doit signaler ces points au porteur de projet avant de
figer des choix irréversibles (schéma de données pour la pièce d'identité, hébergement
des photos, etc.).
