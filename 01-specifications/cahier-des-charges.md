# Cahier des charges fonctionnel

## 1. Vision du produit

Une application mobile de messagerie communautaire où l'organisation des groupes de
discussion est centralisée par un super-utilisateur (l'exploitant de la plateforme),
avec une couche d'anonymat optionnelle par utilisateur et par groupe. L'application est
accompagnée d'une présence sur Facebook et TikTok (comptes/pages officiels, hors périmètre
technique de ce document, sauf pour la redirection de liens — voir section 6).

## 2. Inscription et identité utilisateur

- Numéro de téléphone obligatoire, au format international du Burkina Faso : `+226XXXXXXXX`
  - Validation du format à l'inscription (préfixe +226 imposé)
  - Recommandé : vérification par SMS/OTP (Firebase Phone Authentication) pour éviter les
    faux numéros — à confirmer avec le porteur de projet
- Nom et prénom obligatoires
- Photo de la pièce d'identité, recto et verso, obligatoire
  - **Point de vigilance légal** : la collecte de pièces d'identité est une donnée
    sensible. Il faut prévoir : stockage chiffré, accès restreint (super-utilisateur
    uniquement), politique de rétention/suppression, et idéalement une base légale
    claire (CNIL équivalent local, régulation burkinabè sur les données personnelles).
    Ce point doit être validé avant la mise en production.
- Photo de profil (implicite, à confirmer)

## 3. Mode "Inconnu" (anonymat)

- Chaque utilisateur peut activer/désactiver un "mode inconnu" à tout moment
- Quand il est activé :
  - Le nom affiché de l'utilisateur devient `Inconnu` + un numéro d'ordre séquentiel
    (`Inconnu 1`, `Inconnu 2`, etc.) — **la numérotation est propre à chaque groupe**,
    pas globale (deux utilisateurs anonymes dans deux groupes différents peuvent tous
    les deux être "Inconnu 1" dans leur groupe respectif)
  - Une couleur est attribuée automatiquement à chaque "Inconnu" pour le distinguer
    visuellement des autres (bulle de message, nom affiché)
  - L'identité réelle reste connue en base de données (pour la modération et le
    super-utilisateur) mais n'est pas affichée aux autres membres du groupe
- Le mode inconnu est un attribut utilisateur x groupe, pas un attribut global du compte
  (à confirmer : un utilisateur peut-il être anonyme dans un groupe et identifié dans un
  autre ? Hypothèse retenue par défaut : oui, plus flexible et plus probable au vu du
  brief)

## 4. Messagerie de groupe

### 4.1 Types de contenu supportés
- Texte
- Message vocal
- Vidéo
- Image
- Lien (voir redirections en section 6)

### 4.2 Fonctionnalités de messagerie
- Répondre à un message précis en le citant/mentionnant (comme la fonction "Répondre" de
  WhatsApp)
- Épingler un ou plusieurs messages dans un groupe (visible en haut ou dans une section
  dédiée du groupe)
- Voir le nombre de membres du groupe (aucune limite de taille de groupe)

### 4.3 Restriction majeure : pas de messagerie privée
- Les utilisateurs **ne peuvent pas** s'envoyer de messages directs entre eux (pas de 1-to-1)
- Toute communication passe uniquement par les groupes créés par le super-utilisateur
- Conséquence technique : le modèle de données n'a pas besoin de "conversations privées",
  uniquement des groupes

## 5. Groupes de discussion

- Les groupes sont créés **uniquement** par le super-utilisateur (aucun utilisateur
  standard ne peut créer de groupe)
- À l'ouverture de l'application, l'utilisateur voit la liste de tous les groupes créés
  par le super-utilisateur
- L'utilisateur peut rejoindre ("intégrer") n'importe quel groupe de son choix, sans
  limite de nombre de groupes rejoints
- Pas de limite au nombre de membres par groupe

## 6. Rôles et permissions

### 6.1 Super-utilisateur (admin plateforme, unique ou restreint à quelques comptes)
- Crée les groupes
- Nomme des administrateurs de groupe parmi les membres
- Exclut un membre d'un groupe
- Supprime le compte d'un utilisateur (compte entier, pas seulement l'accès à un groupe)
- Active/désactive la possibilité d'écrire dans un groupe (mode "lecture seule" activable
  par groupe — utile pour des groupes d'annonces)

### 6.2 Administrateur de groupe (nommé par le super-utilisateur)
- Hérite d'une partie des droits du super-utilisateur, limités au groupe où il est nommé :
  - Restreindre un membre (mute / droits limités — comportement exact à préciser :
    empêcher d'écrire, empêcher d'envoyer certains types de contenu, etc.)
  - Exclure un membre du groupe

### 6.3 Utilisateur standard
- Rejoint des groupes existants
- Envoie des messages (texte, vocal, image, vidéo, lien) si le groupe l'autorise
- Répond/mentionne, épingle des messages (si ce droit n'est pas réservé aux admins —
  à confirmer)
- Active/désactive son mode inconnu

## 7. Redirection de liens externes

- Un lien TikTok cliqué dans l'application doit rediriger vers l'application TikTok
  (ou son navigateur si l'app n'est pas installée)
- Un lien Facebook cliqué doit rediriger vers l'application Facebook (ou navigateur)
- Comportement générique attendu : détection du domaine du lien et ouverture via
  "deep linking" natif de la plateforme correspondante quand c'est possible, sinon
  ouverture dans le navigateur par défaut

## 8. Panel d'administration web (ajout du porteur de projet)

Voir `05-panel-admin/panel-admin-angular.md` pour le détail. Résumé : une interface web
Angular permettant au super-utilisateur de gérer visuellement les groupes, les
utilisateurs, la modération et les statistiques, sans dépendre uniquement de l'app
mobile.

## 9. Exigences non fonctionnelles à valider

- Volumétrie attendue (nombre d'utilisateurs cible, nombre de groupes) — impacte les
  choix d'architecture Firestore (voir `03-base-de-donnees`)
- Disponibilité / support hors-ligne (SQLite en cache local suggère un besoin de
  fonctionnement partiellement hors-ligne, à confirmer)
- Modération de contenu (signalement de messages, filtrage automatique ?) — non
  mentionné dans le brief initial, à soulever avec le porteur de projet
